import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../models/lesson.dart';

class DownloadManager extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onDownloadComplete;
  final bool compact; // New parameter for compact mode

  const DownloadManager({
    Key? key,
    required this.lesson,
    this.onDownloadComplete,
    this.compact = false, // Default to full mode
  }) : super(key: key);

  @override
  State<DownloadManager> createState() => _DownloadManagerState();
}

class _DownloadManagerState extends State<DownloadManager> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';
  int _currentFileIndex = 0;
  int _totalFiles = 0;
  String _currentFileName = '';

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    // Check if lesson is already downloaded using FileService
    bool isDownloaded = true;

    if (widget.lesson.pdf != null) {
      isDownloaded = isDownloaded && await FileService.fileExists(widget.lesson.pdf!);
    }

    for (String audioFile in widget.lesson.audio) {
      isDownloaded = isDownloaded && await FileService.fileExists(audioFile);
    }

    if (mounted) {
      setState(() {
        _status = isDownloaded ? 'Downloaded' : 'Not Downloaded';
      });
    }
  }

  Future<void> _downloadLesson() async {
    if (_isDownloading) return;

    // Check if already downloaded
    bool isDownloaded = true;
    if (widget.lesson.pdf != null) {
      isDownloaded = isDownloaded && await FileService.fileExists(widget.lesson.pdf!);
    }
    for (String audioFile in widget.lesson.audio) {
      isDownloaded = isDownloaded && await FileService.fileExists(audioFile);
    }

    if (isDownloaded) {
      setState(() {
        _status = 'Downloaded';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _currentFileIndex = 0;
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
      _totalFiles = widget.lesson.audio.length;
      if (widget.lesson.pdf != null) _totalFiles++;

      int downloadedFiles = 0;

      // Download PDF first if exists and not already downloaded
      if (widget.lesson.pdf != null && !await FileService.fileExists(widget.lesson.pdf!)) {
        setState(() {
          _currentFileIndex = downloadedFiles + 1;
          _currentFileName = widget.lesson.pdf!.split('/').last;
          _status = 'Downloading PDF (${_currentFileIndex}/$_totalFiles)...';
        });

        await ApiService.downloadFile(widget.lesson.pdf!);
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / _totalFiles;
        });
      } else if (widget.lesson.pdf != null) {
        // PDF already exists, skip but count it
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / _totalFiles;
        });
      }

      // Download audio files that don't exist
      for (int i = 0; i < widget.lesson.audio.length; i++) {
        if (!await FileService.fileExists(widget.lesson.audio[i])) {
          setState(() {
            _currentFileIndex = downloadedFiles + 1;
            _currentFileName = widget.lesson.audio[i].split('/').last;
            _status = 'Downloading audio (${_currentFileIndex}/$_totalFiles)...';
          });

          await ApiService.downloadFile(widget.lesson.audio[i]);
        }
        downloadedFiles++;
        setState(() {
          _progress = downloadedFiles / _totalFiles;
        });
      }

      setState(() {
        _status = 'Download Complete!';
        _progress = 1.0;
        _currentFileName = '';
      });

      // Call callback if provided
      widget.onDownloadComplete?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.lesson.name} - $_totalFiles files downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _status = 'Download Failed: ${e.toString()}';
        _currentFileName = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
    // Compact mode for welcome_page
    if (widget.compact) {
      return _buildCompactMode();
    }

    // Full mode for api_lessons_page
    return _buildFullMode();
  }

  Widget _buildCompactMode() {
    if (_isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downloading...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (_currentFileName.isNotEmpty)
                    Text(
                      _currentFileName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'File $_currentFileIndex of $_totalFiles',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      );
    }

    // Show download button or completed status
    if (_status == 'Downloaded') {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 16),
            SizedBox(width: 4),
            Text(
              'Downloaded',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: _downloadLesson,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download, size: 16),
          const SizedBox(width: 4),
          Text(
            'Download (${widget.lesson.audio.length + (widget.lesson.pdf != null ? 1 : 0)} files)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMode() {
    if (_isDownloading) {
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
            // Header with lesson name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lesson.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _status == 'Downloaded' 
                            ? Colors.green 
                            : _status == 'Not Downloaded'
                              ? Colors.orange
                              : Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // File count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.lesson.audio.length + (widget.lesson.pdf != null ? 1 : 0)} files',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Progress section (only show when downloading)
            if (_isDownloading) ...[
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(_progress * 100).toInt()}%',
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
                    value: _progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  
                  // Current file info
                  if (_currentFileName.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.file_download,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentFileName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'File $_currentFileIndex of $_totalFiles',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],

            // File list preview
            if (!_isDownloading) ...[
              Text(
                'Files to download:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...widget.lesson.audio.map((audioFile) => _buildFileItem(
                audioFile.split('/').last,
                Icons.audiotrack,
                Colors.orange,
              )),
              if (widget.lesson.pdf != null)
                _buildFileItem(
                  widget.lesson.pdf!.split('/').last,
                  Icons.picture_as_pdf,
                  Colors.red,
                ),
              const SizedBox(height: 16),
            ],

            // Download button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _status == 'Downloaded' || _isDownloading ? null : _downloadLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _status == 'Downloaded' 
                    ? Colors.grey 
                    : _isDownloading 
                      ? Colors.orange
                      : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isDownloading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Downloading... (${_currentFileIndex}/$_totalFiles)'),
                      ],
                    )
                  : Text(
                      _status == 'Downloaded'
                        ? '✓ Already Downloaded'
                        : 'Download Lesson',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String fileName, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}