import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  static const String _courseAppFolder = 'course_app';

  /// Get base path for file storage based on platform
  static Future<String> getBasePath() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      // Try Download folder first, fallback to external storage
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Desktop platforms
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    return '${directory.path}/$_courseAppFolder';
  }

  /// Get full file path for a given relative path
  static Future<String?> getFilePath(String relativePath) async {
    try {
      final basePath = await getBasePath();
      final fullPath = '$basePath/$relativePath';
      
      if (await File(fullPath).exists()) {
        // For iOS, return file:// protocol for PDF viewer
        if (Platform.isIOS && relativePath.toLowerCase().endsWith('.pdf')) {
          return 'file://$fullPath';
        }
        return fullPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if file exists locally
  static Future<bool> fileExists(String relativePath) async {
    try {
      final filePath = await getFilePath(relativePath);
      if (filePath == null) return false;
      
      // Remove file:// protocol for existence check
      final cleanPath = filePath.replaceFirst('file://', '');
      return await File(cleanPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get platform-specific error message
  static String getErrorMessage(String error) {
    if (Platform.isIOS) {
      return 'File not accessible. Please try downloading again.';
    } else {
      return 'File not found in Downloads folder. Please download first.';
    }
  }

  /// Get file info for UI display
  static Future<Map<String, dynamic>> getFileInfo(String relativePath) async {
    final exists = await fileExists(relativePath);
    final path = await getFilePath(relativePath);
    
    return {
      'exists': exists,
      'path': path,
      'isDownloaded': exists,
    };
  }

  /// Get all downloaded files for a lesson
  static Future<List<String>> getDownloadedFilesForLesson(String lessonName) async {
    try {
      final basePath = await getBasePath();
      final lessonPath = '$basePath/App/$lessonName';
      final lessonDir = Directory(lessonPath);
      
      if (!await lessonDir.exists()) {
        return [];
      }

      final files = await lessonDir.list().toList();
      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }
} 