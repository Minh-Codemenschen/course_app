import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lesson.dart';
import '../widgets/download_manager.dart';
import '../widgets/download_summary.dart';

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
    // Calculate total files to download
    int totalFiles = 0;
    for (Lesson lesson in _lessons) {
      totalFiles += lesson.audio.length;
      if (lesson.pdf != null) totalFiles++;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BulkDownloadDialog(
        totalLessons: _lessons.length,
        totalFiles: totalFiles,
        lessons: _lessons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Lessons'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
        actions: [
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading lessons',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
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

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // Download Summary
        DownloadSummary(
          lessons: _lessons,
          onRefresh: () {
            setState(() {
              // Refresh the page
            });
          },
        ),
        
        // Individual lesson download managers
        ..._lessons.map((lesson) => DownloadManager(
          lesson: lesson,
          onDownloadComplete: () {
            // Optionally refresh the list or update UI
          },
        )),
      ],
    );
  }
}

class BulkDownloadDialog extends StatefulWidget {
  final int totalLessons;
  final int totalFiles;
  final List<Lesson> lessons;

  const BulkDownloadDialog({
    Key? key,
    required this.totalLessons,
    required this.totalFiles,
    required this.lessons,
  }) : super(key: key);

  @override
  State<BulkDownloadDialog> createState() => _BulkDownloadDialogState();
}

class _BulkDownloadDialogState extends State<BulkDownloadDialog> {
  int _downloadedLessons = 0;
  int _downloadedFiles = 0;
  String _currentLesson = '';
  String _currentFile = '';
  bool _isDownloading = false;
  List<String> _failedLessons = [];

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    for (int i = 0; i < widget.lessons.length; i++) {
      final lesson = widget.lessons[i];
      
      setState(() {
        _currentLesson = lesson.name;
      });

      try {
        // Convert lesson to Map for API service
        Map<String, dynamic> lessonMap = {
          'name': lesson.name,
          'pdf': lesson.pdf,
          'audio': lesson.audio,
        };

        // Download all files for this lesson
        final downloadedFiles = await ApiService.downloadLessonFiles(lessonMap);
        
        setState(() {
          _downloadedFiles += downloadedFiles.length;
          _downloadedLessons++;
        });

      } catch (e) {
        setState(() {
          _failedLessons.add('${lesson.name}: ${e.toString()}');
        });
      }
    }

    setState(() {
      _isDownloading = false;
    });

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _failedLessons.isEmpty ? Icons.check_circle : Icons.warning,
              color: _failedLessons.isEmpty ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(_failedLessons.isEmpty ? 'Download Complete' : 'Download Finished'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully downloaded:'),
            Text('• $_downloadedLessons lessons', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('• $_downloadedFiles files', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_failedLessons.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Failed downloads:', style: TextStyle(color: Colors.red)),
              ..._failedLessons.map((failure) => Text('• $failure', style: const TextStyle(fontSize: 12))),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close completion dialog
              Navigator.of(context).pop(); // Close bulk download dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Downloading All Lessons'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lessons: $_downloadedLessons/${widget.totalLessons}'),
              Text('Files: $_downloadedFiles/${widget.totalFiles}'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          LinearProgressIndicator(
            value: widget.totalLessons > 0 ? _downloadedLessons / widget.totalLessons : 0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          
          // Current lesson info
          if (_currentLesson.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.folder, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentLesson,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Status text
          Text(
            _isDownloading ? 'Downloading...' : 'Complete!',
            style: TextStyle(
              fontSize: 12,
              color: _isDownloading ? Colors.blue : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}