import 'package:flutter/material.dart';
import '../services/file_service.dart';
import '../models/lesson.dart';

class DownloadSummary extends StatefulWidget {
  final List<Lesson> lessons;
  final VoidCallback? onRefresh;

  const DownloadSummary({
    Key? key,
    required this.lessons,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<DownloadSummary> createState() => _DownloadSummaryState();
}

class _DownloadSummaryState extends State<DownloadSummary> {
  bool _isLoading = true;
  int _totalFiles = 0;
  int _downloadedFiles = 0;
  int _totalLessons = 0;
  int _completedLessons = 0;

  @override
  void initState() {
    super.initState();
    _calculateDownloadStatus();
  }

  Future<void> _calculateDownloadStatus() async {
    setState(() {
      _isLoading = true;
    });

    _totalFiles = 0;
    _downloadedFiles = 0;
    _totalLessons = widget.lessons.length;
    _completedLessons = 0;

    for (Lesson lesson in widget.lessons) {
      bool lessonComplete = true;
      
      // Count PDF
      if (lesson.pdf != null) {
        _totalFiles++;
        final pdfExists = await FileService.fileExists(lesson.pdf!);
        if (pdfExists) {
          _downloadedFiles++;
        } else {
          lessonComplete = false;
        }
      }

      // Count audio files
      for (String audioFile in lesson.audio) {
        _totalFiles++;
        final audioExists = await FileService.fileExists(audioFile);
        if (audioExists) {
          _downloadedFiles++;
        } else {
          lessonComplete = false;
        }
      }

      if (lessonComplete) {
        _completedLessons++;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  double get _progressPercentage {
    if (_totalFiles == 0) return 0.0;
    return _downloadedFiles / _totalFiles;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Calculating download status...'),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.download, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Download Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    _calculateDownloadStatus();
                    widget.onRefresh?.call();
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(_progressPercentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progressPercentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Lessons',
                    '$_completedLessons/$_totalLessons',
                    Icons.folder,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Files',
                    '$_downloadedFiles/$_totalFiles',
                    Icons.file_copy,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_progressPercentage == 1.0) return Colors.green;
    if (_progressPercentage > 0.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_progressPercentage == 1.0) return Icons.check_circle;
    if (_progressPercentage > 0.5) return Icons.pending;
    return Icons.download;
  }

  String _getStatusMessage() {
    if (_progressPercentage == 1.0) {
      return 'All lessons downloaded successfully!';
    } else if (_progressPercentage > 0.5) {
      return 'Most lessons downloaded. Continue downloading remaining files.';
    } else if (_progressPercentage > 0) {
      return 'Some lessons downloaded. Consider downloading all lessons for offline access.';
    } else {
      return 'No lessons downloaded yet. Download lessons to access content offline.';
    }
  }
} 