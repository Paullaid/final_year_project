import { AwsClient } from "aws4fetch";
import { decodeProtectedHeader, importX509, jwtVerify } from "jose";

/**
 * Pre-signs GET requests to Cloudflare R2 (S3-compatible) for 1 hour.
 *
 * Security:
 * - Never commit R2 access keys. Configure them with Wrangler secrets:
 *   - R2_ACCESS_KEY_ID
 *   - R2_SECRET_ACCESS_KEY
 *
 * Optional hardening:
 * - Validate Firebase ID tokens before signing (implemented when FIREBASE_PROJECT_ID is set).
 * - Restrict allowed path prefixes.
 */
let certCache = {
  exp: 0,
  certs: null,
};

export default {
  async fetch(request, env) {
    try {
      const accessKeyId = env.R2_ACCESS_KEY_ID;
      const secretAccessKey = env.R2_SECRET_ACCESS_KEY;
      const accountId = env.R2_ACCOUNT_ID;
      const bucket = env.R2_BUCKET_NAME;

      if (!accessKeyId || !secretAccessKey) {
        return json(500, { error: "Worker is missing R2 credentials (Wrangler secrets)" });
      }
      if (!accountId || !bucket) {
        return json(500, { error: "Worker is missing R2_ACCOUNT_ID / R2_BUCKET_NAME" });
      }
      const url = new URL(request.url);
      const path = url.pathname.replace(/^\/+/, "");

      if (path.startsWith("admin/")) {
        if (env.FIREBASE_PROJECT_ID) {
          const auth = await verifyFirebaseToken(request, env.FIREBASE_PROJECT_ID);
          if (!auth.ok) return json(401, { error: auth.error });
          if (!isAdmin(auth.payload)) return json(403, { error: "Admin role required" });
        }
        return handleAdminRoutes(request, env, path, { accessKeyId, secretAccessKey, accountId, bucket });
      }

      if (request.method !== "GET" && request.method !== "HEAD") {
        return json(405, { error: "Method not allowed" });
      }
      if (env.FIREBASE_PROJECT_ID) {
        const auth = await verifyFirebaseToken(request, env.FIREBASE_PROJECT_ID);
        if (!auth.ok) return json(401, { error: auth.error });
      }

      let filePath = path;
      try {
        filePath = decodeURIComponent(filePath);
      } catch {
        return json(400, { error: "Invalid path encoding" });
      }

      if (!filePath || filePath.includes("..")) {
        return json(400, { error: "Missing or invalid file path" });
      }

      const r2 = new AwsClient({
        accessKeyId,
        secretAccessKey,
        service: "s3",
        region: "auto",
      });

      const target = `https://${accountId}.r2.cloudflarestorage.com/${bucket}/${filePath}`;
      const r2Request = new Request(target, { method: "GET" });
      const signed = await r2.sign(r2Request, {
        aws: { signQuery: true },
        headers: { "X-Amz-Expires": "3600" },
      });

      return new Response(JSON.stringify({ url: signed.url }), {
        status: 200,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Cache-Control": "no-store",
        },
      });
    } catch (e) {
      return json(500, { error: "Failed to sign URL", detail: String(e) });
    }
  },
};

function json(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store",
    },
  });
}

async function verifyFirebaseToken(request, projectId) {
  const authHeader = request.headers.get("authorization") || "";
  if (!authHeader.startsWith("Bearer ")) {
    return { ok: false, error: "Missing Bearer token" };
  }

  const token = authHeader.slice("Bearer ".length).trim();
  if (!token) {
    return { ok: false, error: "Empty Bearer token" };
  }

  try {
    const header = decodeProtectedHeader(token);
    const kid = header.kid;
    if (!kid) {
      return { ok: false, error: "Token missing key id (kid)" };
    }

    const certs = await getFirebaseCerts();
    const certPem = certs[kid];
    if (!certPem) {
      return { ok: false, error: "Unknown token key id" };
    }

    const key = await importX509(certPem, "RS256");
    const verified = await jwtVerify(token, key, {
      algorithms: ["RS256"],
      issuer: `https://securetoken.google.com/${projectId}`,
      audience: projectId,
    });
    return { ok: true, payload: verified.payload };
  } catch (e) {
    return { ok: false, error: `Invalid Firebase token: ${String(e)}` };
  }
}

async function getFirebaseCerts() {
  const now = Date.now();
  if (certCache.certs && certCache.exp > now) {
    return certCache.certs;
  }

  const res = await fetch(
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com",
  );
  if (!res.ok) {
    throw new Error(`Failed to fetch Firebase certs (${res.status})`);
  }
  const certs = await res.json();
  const cacheControl = res.headers.get("cache-control") || "";
  const maxAge = parseMaxAge(cacheControl) ?? 3600;
  certCache = {
    certs,
    exp: now + maxAge * 1000,
  };
  return certs;
}

function parseMaxAge(cacheControl) {
  const m = /max-age=(\d+)/i.exec(cacheControl);
  if (!m) return null;
  const value = Number.parseInt(m[1], 10);
  return Number.isFinite(value) ? value : null;
}

function isAdmin(payload) {
  if (!payload) return false;
  const role = payload.role?.toString().toLowerCase();
  return role === "admin" || payload.admin === true || payload.isAdmin === true;
}

async function handleAdminRoutes(request, env, path, creds) {
  const r2 = new AwsClient({
    accessKeyId: creds.accessKeyId,
    secretAccessKey: creds.secretAccessKey,
    service: "s3",
    region: "auto",
  });

  if (path === "admin/upload" && request.method === "PUT") {
    const url = new URL(request.url);
    const rawCode = (url.searchParams.get("courseCode") || "misc").trim();
    const courseCode = rawCode.toLowerCase().replace(/[^a-z0-9]/g, "");
    const year = url.searchParams.get("year") || `${new Date().getFullYear()}`;
    const sem = url.searchParams.get("semester") || "1";
    const fileName = (url.searchParams.get("filename") || "paper.pdf").replace(/[^\w.\-]/g, "_");
    const ts = Date.now();
    const r2Path = `courses/${courseCode}/${year}_sem${sem}_${ts}_${fileName}`;
    const target = `https://${creds.accountId}.r2.cloudflarestorage.com/${creds.bucket}/${r2Path}`;

    const putReq = new Request(target, {
      method: "PUT",
      headers: { "Content-Type": request.headers.get("content-type") || "application/pdf" },
      body: request.body,
    });
    const signedPut = await r2.sign(putReq);
    const putRes = await fetch(signedPut);
    if (!putRes.ok) {
      const body = await putRes.text();
      return json(500, { error: `R2 upload failed (${putRes.status})`, detail: body });
    }
    return json(200, { r2Path });
  }

  if (path === "admin/delete" && request.method === "DELETE") {
    const body = await request.json().catch(() => ({}));
    const r2Path = body?.r2Path?.toString();
    if (!r2Path || r2Path.includes("..")) {
      return json(400, { error: "Invalid r2Path" });
    }
    const target = `https://${creds.accountId}.r2.cloudflarestorage.com/${creds.bucket}/${r2Path}`;
    const delReq = new Request(target, { method: "DELETE" });
    const signedDel = await r2.sign(delReq);
    const delRes = await fetch(signedDel);
    if (!delRes.ok && delRes.status !== 404) {
      const text = await delRes.text();
      return json(500, { error: `R2 delete failed (${delRes.status})`, detail: text });
    }
    return json(200, { deleted: true, r2Path });
  }

  return json(405, { error: "Unsupported admin route/method" });
}
