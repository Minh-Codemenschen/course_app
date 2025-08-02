import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CrossPlatformPdfViewer extends StatelessWidget {
  final String filePath;
  final String? title;

  const CrossPlatformPdfViewer({
    Key? key,
    required this.filePath,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check platform and return appropriate viewer
    if (kIsWeb) {
      return _buildWebViewer(context);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return _buildDesktopViewer(context);
    } else {
      // Mobile platforms (Android, iOS)
      return _buildMobileViewer(context);
    }
  }

  Widget _buildWebViewer(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'PDF Viewer'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('PDF viewing is not supported on web platform'),
      ),
    );
  }

  Widget _buildDesktopViewer(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'PDF Viewer'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openWithSystemViewer(context),
            tooltip: 'Open with System Viewer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PDF File: ${filePath.split('/').last}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Path: $filePath',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openWithSystemViewer(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open with System'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // PDF Viewer
          Expanded(
            child: _buildPdfViewer(),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    try {
      // Try to use Syncfusion PDF viewer (works on all platforms)
      return SfPdfViewer.file(
        File(filePath),
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      );
    } catch (e) {
      // Fallback to flutter_pdfview for mobile if Syncfusion fails
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          return PDFView(
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
          );
        } catch (e2) {
          return _buildFallbackViewer();
        }
      } else {
        return _buildFallbackViewer();
      }
    }
  }

  Widget _buildFallbackViewer() {
    return Builder(
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'PDF File: ${filePath.split('/').last}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Path: $filePath',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to display PDF in app.\nPlease use system viewer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openWithSystemViewer(context),
              child: const Text('Open with System Viewer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWithSystemViewer(BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF file not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback for Windows
        if (Platform.isWindows) {
          final result = await Process.run('start', [filePath], runInShell: true);
          if (result.exitCode != 0) {
            throw Exception('Failed to open file');
          }
        } else {
          throw Exception('Cannot open file with system viewer');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMobileViewer(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'PDF Viewer'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
      ),
      body: _buildPdfViewer(),
    );
  }
} 