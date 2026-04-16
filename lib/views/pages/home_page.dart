import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:past_questions/views/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();

  bool _loading = true;
  List<Map<String, dynamic>> _all = const [];
  List<Map<String, dynamic>> _filtered = const [];

  late final AnimationController _listAnim;

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _seedLoad();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.dispose();
    _listAnim.dispose();
    super.dispose();
  }

  Future<void> _seedLoad() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final data = <Map<String, dynamic>>[
      {
        "id": "1",
        "course": "CSC 101 – Introduction to Programming",
        "year": "2023",
        "downloads": 245,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "2",
        "course": "CSC 201 – Data Structures",
        "year": "2022",
        "downloads": 189,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "3",
        "course": "MTH 101 – Calculus I",
        "year": "2021",
        "downloads": 312,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "4",
        "course": "PHY 102 – Electricity & Magnetism",
        "year": "2023",
        "downloads": 98,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "5",
        "course": "STA 201 – Probability & Statistics",
        "year": "2020",
        "downloads": 154,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "6",
        "course": "CHM 101 – General Chemistry",
        "year": "2022",
        "downloads": 121,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "7",
        "course": "CSC 301 – Operating Systems",
        "year": "2021",
        "downloads": 207,
        "url": "https://example.com/pastquestion.pdf",
      },
      {
        "id": "8",
        "course": "CSC 401 – Artificial Intelligence",
        "year": "2023",
        "downloads": 76,
        "url": "https://example.com/pastquestion.pdf",
      },
    ];

    if (!mounted) return;
    setState(() {
      _all = data;
      _filtered = data;
      _loading = false;
    });
    _listAnim.forward(from: 0);
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _applyFilter();
    _listAnim.forward(from: 0);
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    final next = q.isEmpty
        ? _all
        : _all.where((item) {
            final course = (item["course"] ?? "").toString().toLowerCase();
            final year = (item["year"] ?? "").toString().toLowerCase();
            return course.contains(q) || year.contains(q);
          }).toList(growable: false);
    if (!mounted) return;
    setState(() => _filtered = next);
  }

  String _userDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    final dn = user?.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Guest';
  }

  void _download(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Download started…',
          style: GoogleFonts.lato(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final blobA = (isDark ? Colors.lightBlueAccent : Colors.blue.shade100)
        .withOpacity(isDark ? 0.08 : 0.14);
    final blobB = (isDark ? Colors.white : Colors.blue.shade200)
        .withOpacity(isDark ? 0.05 : 0.10);

    final glass = isDark
        ? Colors.black.withOpacity(0.30)
        : Colors.white.withOpacity(0.22);

    final name = _userDisplayName();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surface,
                    isDark ? Colors.black.withOpacity(0.22) : Colors.blue.shade50,
                    scheme.surface,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Positioned(top: -60, left: -40, child: _Blob(diameter: 240, color: blobA)),
          Positioned(
            bottom: -90,
            right: -60,
            child: _Blob(diameter: 300, color: blobB),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DotsPainter(
                  color: (isDark ? Colors.white : Colors.blueGrey)
                      .withOpacity(isDark ? 0.06 : 0.10),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Past Questions',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => SettingsPage(title: 'Settings'),
                          ),
                        );
                      },
                      icon: Icon(Icons.settings_outlined, color: scheme.primary),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeOutCubic,
                            builder: (context, t, child) {
                              return Opacity(
                                opacity: t,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - t) * 14),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Welcome, $name',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    height: 1.05,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Find and download past question papers by course or year.',
                                  style: GoogleFonts.lato(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: scheme.onSurface
                                        .withOpacity(isDark ? 0.72 : 0.64),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: glass,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(
                                            isDark ? 0.08 : 0.20,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              isDark ? 0.45 : 0.12,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 14),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.search, color: scheme.primary),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: _search,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Search by course title or year…',
                                                hintStyle: GoogleFonts.lato(
                                                  color: scheme.onSurface
                                                      .withOpacity(isDark ? 0.38 : 0.46),
                                                ),
                                                border: InputBorder.none,
                                              ),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (_search.text.isNotEmpty)
                                            IconButton(
                                              onPressed: () {
                                                _search.clear();
                                                _applyFilter();
                                              },
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: scheme.onSurface.withOpacity(
                                                  isDark ? 0.70 : 0.60,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_loading) ...[
                                  _ShimmerList(isDark: isDark),
                                ] else if (_filtered.isEmpty) ...[
                                  const SizedBox(height: 18),
                                  Center(
                                    child: Text(
                                      'No past questions found',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface.withOpacity(
                                          isDark ? 0.70 : 0.62,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 260),
                                ] else ...[
                                  Text(
                                    'Available papers',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      letterSpacing: 1.6,
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface.withOpacity(
                                        isDark ? 0.66 : 0.62,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filtered.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = _filtered[index];
                                      final anim = CurvedAnimation(
                                        parent: _listAnim,
                                        curve: Interval(
                                          (index / (_filtered.length + 6))
                                              .clamp(0.0, 1.0),
                                          1,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      );

                                      return FadeTransition(
                                        opacity: anim,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.08),
                                            end: Offset.zero,
                                          ).animate(anim),
                                          child: _PastQuestionCard(
                                            item: item,
                                            onDownload: () => _download(item),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Upload coming soon…',
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.upload_rounded),
      ),
    );
  }
}

class _PastQuestionCard extends StatelessWidget {
  const _PastQuestionCard({required this.item, required this.onDownload});

  final Map<String, dynamic> item;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        scheme.surface.withOpacity(isDark ? 0.55 : 0.92),
        (isDark ? Colors.lightBlueAccent : Colors.blue.shade50)
            .withOpacity(isDark ? 0.10 : 0.70),
        scheme.surface.withOpacity(isDark ? 0.55 : 0.92),
      ],
      stops: const [0, 0.55, 1],
    );

    final course = (item["course"] ?? "Course").toString();
    final year = (item["year"] ?? "").toString();
    final downloads = (item["downloads"] ?? 0).toString();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(isDark ? 0.20 : 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.10),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: scheme.primary.withOpacity(isDark ? 0.20 : 0.10),
              ),
              child: Icon(
                Icons.description_outlined,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Pill(
                        icon: Icons.calendar_month_outlined,
                        label: year,
                      ),
                      _Pill(
                        icon: Icons.download_done_rounded,
                        label: '$downloads downloads',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _DownloadButton(onPressed: onDownload),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.lightBlueAccent.withOpacity(isDark ? 0.85 : 1),
        scheme.primary.withOpacity(isDark ? 0.85 : 1),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        tooltip: 'Download',
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(isDark ? 0.28 : 0.80),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withOpacity(isDark ? 0.18 : 0.40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withOpacity(isDark ? 0.78 : 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatefulWidget {
  const _ShimmerList({required this.isDark});

  final bool isDark;

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surface.withOpacity(widget.isDark ? 0.35 : 0.75);
    final highlight = (widget.isDark ? Colors.white : Colors.lightBlueAccent)
        .withOpacity(widget.isDark ? 0.10 : 0.22);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Column(
          children: List.generate(6, (i) {
            final dx = (t * 2 - 1) * 0.9;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment(-1 + dx, -0.2),
                      end: Alignment(1 + dx, 0.2),
                      colors: [base, highlight, base],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    height: 86,
                    color: base,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 42,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    void dot(double x, double y, double r) =>
        canvas.drawCircle(Offset(x, y), r, paint);

    dot(size.width * 0.12, size.height * 0.18, 1.4);
    dot(size.width * 0.28, size.height * 0.32, 1.0);
    dot(size.width * 0.84, size.height * 0.20, 1.2);
    dot(size.width * 0.72, size.height * 0.58, 1.0);
    dot(size.width * 0.18, size.height * 0.80, 1.1);

    final line = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.56),
      Offset(size.width * 0.30, size.height * 0.52),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, size.height * 0.40),
      Offset(size.width * 0.90, size.height * 0.44),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}