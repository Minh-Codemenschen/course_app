import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lesson.dart';
import '../widgets/download_manager.dart';

class ApiLessonsPage extends StatefulWidget {
  const ApiLessonsPage({super.key});

  @override
  State<ApiLessonsPage> createState() => _ApiLessonsPageState();
}

class _ApiLessonsPageState extends State<ApiLessonsPage> {
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ApiService.fetchLessons();
      final lessonsData = data['lessons'] as List;

      final lessons = lessonsData
          .map((lessonData) => Lesson.fromJson(lessonData))
          .toList();

      // Sort lessons by name to ensure proper order
      lessons.sort((a, b) {
        // Extract lesson numbers for proper sorting
        final aNum = _extractLessonNumber(a.name);
        final bNum = _extractLessonNumber(b.name);
        return aNum.compareTo(bNum);
      });

      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int _extractLessonNumber(String lessonName) {
    // Extract number from lesson names like "Lektion 1", "Lektion 10", etc.
    final regex = RegExp(r'Lektion (\d+)');
    final match = regex.firstMatch(lessonName);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    // For non-numeric lessons, assign high number to put them at the end
    return 999;
  }

  Future<void> _downloadAllLessons() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Downloading all lessons...'),
          ],
        ),
      ),
    );

    try {
      int downloadedCount = 0;
      for (Lesson lesson in _lessons) {
        try {
          Map<String, dynamic> lessonMap = {
            'name': lesson.name,
            'pdf': lesson.pdf,
            'audio': lesson.audio,
          };

          await ApiService.downloadLessonFiles(lessonMap);
          downloadedCount++;
        } catch (e) {
          // ignore: avoid_print
          print('Failed to download ${lesson.name}: $e');
        }
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded $downloadedCount out of ${_lessons.length} lessons'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Lessons'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLessons,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadAllLessons,
            tooltip: 'Download All Lessons',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading lessons from API...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading lessons',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLessons,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_lessons.isEmpty) {
      return const Center(
        child: Text('No lessons available'),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total lessons: ${_lessons.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              final lesson = _lessons[index];
              return DownloadManager(
                lesson: lesson,
                onDownloadComplete: () {
                  // Refresh the list to update download status
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}