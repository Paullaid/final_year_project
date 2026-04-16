import 'package:flutter/material.dart';
import 'package:past_questions/services/local_database.dart';
import 'package:past_questions/services/firestore_sync_service.dart';

/// Runs Firebase → SQLite sync on app start (offline-first: never blocks the UI when cache exists).
class SyncWrapper extends StatefulWidget {
  const SyncWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<SyncWrapper> createState() => _SyncWrapperState();
}

class _SyncWrapperState extends State<SyncWrapper> {
  bool _resolving = true;
  bool _firstSyncBlocking = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final count = await LocalDatabase.instance.questionCount();
      if (!mounted) return;

      if (count == 0) {
        setState(() {
          _resolving = false;
          _firstSyncBlocking = true;
        });
        final service = FirestoreSyncService();
        final outcome = await service.fullSync();
        if (!mounted) return;
        if (!outcome.success) {
          final msg = outcome.message ?? 'Sync failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
          );
        }
        setState(() => _firstSyncBlocking = false);
      } else {
        setState(() => _resolving = false);
        final service = FirestoreSyncService();
        service.incrementalSync().then((outcome) {
          if (!mounted) return;
          if (!outcome.success) {
            final msg = outcome.message ?? 'Sync failed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
            );
          }
        }).catchError((e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Startup sync error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _resolving = false;
          _firstSyncBlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_firstSyncBlocking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Syncing past questions…'),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
