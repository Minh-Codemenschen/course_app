import 'package:flutter/material.dart';
import 'dart:io';
import '../services/file_service.dart';

class FileHandler {
  /// Handle PDF file loading with proper error handling
  static Future<String?> getPdfPath(String relativePath, BuildContext context) async {
    try {
      final filePath = await FileService.getFilePath(relativePath);
      
      if (filePath != null) {
        return filePath;
      } else {
        // Show error dialog
        _showFileErrorDialog(
          context, 
          'PDF File Not Found',
          'The PDF file has not been downloaded yet. Please download the lesson first.',
          relativePath
        );
        return null;
      }
    } catch (e) {
      _showFileErrorDialog(
        context, 
        'Error Loading PDF',
        FileService.getErrorMessage(e.toString()),
        relativePath
      );
      return null;
    }
  }

  /// Handle audio file loading with proper error handling
  static Future<String?> getAudioPath(String relativePath, BuildContext context) async {
    try {
      final filePath = await FileService.getFilePath(relativePath);
      
      if (filePath != null) {
        return filePath;
      } else {
        // Show error dialog
        _showFileErrorDialog(
          context, 
          'Audio File Not Found',
          'The audio file has not been downloaded yet. Please download the lesson first.',
          relativePath
        );
        return null;
      }
    } catch (e) {
      _showFileErrorDialog(
        context, 
        'Error Loading Audio',
        FileService.getErrorMessage(e.toString()),
        relativePath
      );
      return null;
    }
  }

  /// Check if file is downloaded
  static Future<bool> isFileDownloaded(String relativePath) async {
    return await FileService.fileExists(relativePath);
  }

  /// Get download status for multiple files
  static Future<Map<String, bool>> getFilesDownloadStatus(List<String> filePaths) async {
    Map<String, bool> status = {};
    
    for (String path in filePaths) {
      status[path] = await FileService.fileExists(path);
    }
    
    return status;
  }

  /// Show error dialog for file issues
  static void _showFileErrorDialog(
    BuildContext context, 
    String title, 
    String message, 
    String filePath
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              SizedBox(height: 8),
              Text(
                'File: $filePath',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show download required dialog
  static void showDownloadRequiredDialog(BuildContext context, String lessonName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text('Download Required'),
            ],
          ),
          content: Text(
            'The files for "$lessonName" need to be downloaded before you can view or play them. Would you like to download them now?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to download page or trigger download
                // This will be handled by the calling widget
              },
              child: Text('Download'),
            ),
          ],
        );
      },
    );
  }

  /// Get platform-specific file access info
  static String getPlatformFileAccessInfo() {
    if (Platform.isAndroid) {
      return 'Files are stored in your Downloads folder under "course_app"';
    } else if (Platform.isIOS) {
      return 'Files are stored in the app\'s documents directory and can be shared via the share button';
    } else {
      return 'Files are stored in the app\'s documents directory';
    }
  }

  /// Check if all lesson files are downloaded
  static Future<bool> isLessonFullyDownloaded({
    String? pdfPath,
    List<String>? audioPaths,
  }) async {
    bool allDownloaded = true;

    // Check PDF
    if (pdfPath != null) {
      allDownloaded = allDownloaded && await FileService.fileExists(pdfPath);
    }

    // Check audio files
    if (audioPaths != null) {
      for (String audioPath in audioPaths) {
        allDownloaded = allDownloaded && await FileService.fileExists(audioPath);
      }
    }

    return allDownloaded;
  }
} 