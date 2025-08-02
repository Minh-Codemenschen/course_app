import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lesson.dart';

class DownloadManager extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onDownloadComplete;

  const DownloadManager({
    Key? key,
    required this.lesson,
    this.onDownloadComplete,
  }) : super(key: key);

  @override
  State<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    // Check if lesson is already downloaded
    bool isDownloaded = true;

    if (widget.lesson.pdf != null) {
      isDownloaded = isDownloaded && await ApiService.fileExistsLocally(widget.lesson.pdf!);
    }

    for (String audioFile in widget.lesson.audio) {
      isDownloaded = isDownloaded && await ApiService.fileExistsLocally(audioFile);
    }

    if (mounted) {
      setState(() {
        _status = isDownloaded ? 'Downloaded' : 'Not Downloaded';
      });
    }
  }

  Future<void> _downloadLesson() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Starting download...';
    });

    try {
      // Convert lesson to Map for API service
      Map<String, dynamic> lessonMap = {
        'name': widget.lesson.name,
        'pdf': widget.lesson.pdf,
        'audio': widget.lesson.audio,
      };

      // Calculate total files to download
      int totalFiles = widget.lesson.audio.length;
      if (widget.lesson.pdf != null) totalFiles++;

      int downloadedFiles = 0;

      // Download PDF first if exists
      if (widget.lesson.pdf != null) {
        setState(() {
          _status = 'Downloading PDF...';
        });

        await ApiService.downloadFile(widget.lesson.pdf!);
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / totalFiles;
        });
      }

      // Download audio files
      for (int i = 0; i < widget.lesson.audio.length; i++) {
        setState(() {
          _status = 'Downloading audio ${i + 1}/${widget.lesson.audio.length}...';
        });

        await ApiService.downloadFile(widget.lesson.audio[i]);
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / totalFiles;
        });
      }

      setState(() {
        _status = 'Download Complete!';
        _progress = 1.0;
      });

      // Call callback if provided
      widget.onDownloadComplete?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.lesson.name} downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      setState(() {
        _status = 'Download Failed: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.lesson.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _status == 'Downloaded' ? Icons.check_circle : Icons.download,
                  color: _status == 'Downloaded' ? Colors.green : Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'PDF: ${widget.lesson.pdf != null ? "Available" : "Not available"}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Audio files: ${widget.lesson.audio.length}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: _status.contains('Failed') ? Colors.red : Colors.grey[600],
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _progress),
            ],
            const SizedBox(height: 12),
                        SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _status == 'Downloaded' || _isDownloading ? null : _downloadLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _status == 'Downloaded' ? Colors.grey : Colors.blue,
                ),
                child: _isDownloading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Downloading...'),
                      ],
                    )
                  : Text(
                      _status == 'Downloaded'
                        ? 'Already Downloaded'
                        : 'Download Lesson',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}