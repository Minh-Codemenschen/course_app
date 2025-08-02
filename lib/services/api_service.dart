import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'file_service.dart';

class ApiService {
  static const String baseUrl = 'https://codemenschen.at/course_app/';

  // Fetch lessons data from API
  static Future<Map<String, dynamic>> fetchLessons() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate the response structure
        if (data is! Map<String, dynamic> || !data.containsKey('lessons')) {
          throw Exception('Invalid response format from API');
        }

        return data;
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Download a file from the API
  static Future<String?> downloadFile(String filePath) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // Create download URL
      final downloadUrl = '$baseUrl$filePath';

      // Get the base path using FileService
      final basePath = await FileService.getBasePath();

      // Create course_app folder if it doesn't exist
      final courseAppDir = Directory(basePath);
      if (!await courseAppDir.exists()) {
        await courseAppDir.create(recursive: true);
      }

      // Extract folder path and filename
      final pathParts = filePath.split('/');
      final fileName = pathParts.last;
      final folderPath = pathParts.sublist(0, pathParts.length - 1).join('/');

      // Create folder structure
      final targetFolder = Directory('$basePath/$folderPath');
      if (!await targetFolder.exists()) {
        await targetFolder.create(recursive: true);
      }

      final file = File('${targetFolder.path}/$fileName');

      // Download the file
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else if (response.statusCode == 404) {
        throw Exception('File not found on server: $filePath');
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  // Download all files for a lesson
  static Future<List<String>> downloadLessonFiles(Map<String, dynamic> lesson) async {
    List<String> downloadedFiles = [];

    try {
      // Download PDF if exists
      if (lesson['pdf'] != null) {
        final pdfPath = await downloadFile(lesson['pdf']);
        if (pdfPath != null) {
          downloadedFiles.add(pdfPath);
        }
      }

      // Download audio files
      if (lesson['audio'] != null) {
        for (String audioFile in lesson['audio']) {
          try {
            final audioPath = await downloadFile(audioFile);
            if (audioPath != null) {
              downloadedFiles.add(audioPath);
            }
          } catch (e) {
            // ignore: avoid_print
            print('Failed to download audio file $audioFile: $e');
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to download lesson files: $e');
    }

    return downloadedFiles;
  }

  // Check if file exists locally using FileService
  static Future<bool> fileExistsLocally(String filePath) async {
    return await FileService.fileExists(filePath);
  }

  // Get local file path using FileService
  static Future<String?> getLocalFilePath(String filePath) async {
    return await FileService.getFilePath(filePath);
  }

  // Get lesson download status
  static Future<Map<String, dynamic>> getLessonDownloadStatus(Map<String, dynamic> lesson) async {
    bool isDownloaded = true;
    List<String> missingFiles = [];

    // Check PDF
    if (lesson['pdf'] != null) {
      final pdfExists = await FileService.fileExists(lesson['pdf']);
      if (!pdfExists) {
        isDownloaded = false;
        missingFiles.add(lesson['pdf']);
      }
    }

    // Check audio files
    if (lesson['audio'] != null) {
      for (String audioFile in lesson['audio']) {
        final audioExists = await FileService.fileExists(audioFile);
        if (!audioExists) {
          isDownloaded = false;
          missingFiles.add(audioFile);
        }
      }
    }

    return {
      'isDownloaded': isDownloaded,
      'missingFiles': missingFiles,
      'totalFiles': (lesson['pdf'] != null ? 1 : 0) + (lesson['audio']?.length ?? 0),
      'downloadedFiles': (lesson['pdf'] != null ? 1 : 0) + (lesson['audio']?.length ?? 0) - missingFiles.length,
    };
  }
}