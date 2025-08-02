import 'package:flutter/material.dart';
import '../services/file_service.dart';

class DownloadStatusButton extends StatefulWidget {
  final String filePath;
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;

  const DownloadStatusButton({
    Key? key,
    required this.filePath,
    required this.child,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  State<DownloadStatusButton> createState() => _DownloadStatusButtonState();
}

class _DownloadStatusButtonState extends State<DownloadStatusButton> {
  bool _isDownloaded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final exists = await FileService.fileExists(widget.filePath);
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!_isDownloaded) {
      return Tooltip(
        message: widget.tooltip ?? 'File not downloaded. Please download the lesson first.',
        child: Opacity(
          opacity: 0.5,
          child: widget.child,
        ),
      );
    }

    return widget.child;
  }
}

class DownloadStatusIcon extends StatefulWidget {
  final String filePath;
  final double size;

  const DownloadStatusIcon({
    Key? key,
    required this.filePath,
    this.size = 16,
  }) : super(key: key);

  @override
  State<DownloadStatusIcon> createState() => _DownloadStatusIconState();
}

class _DownloadStatusIconState extends State<DownloadStatusIcon> {
  bool _isDownloaded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final exists = await FileService.fileExists(widget.filePath);
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isDownloaded) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: widget.size,
      );
    } else {
      return Icon(
        Icons.download,
        color: Colors.orange,
        size: widget.size,
      );
    }
  }
} 