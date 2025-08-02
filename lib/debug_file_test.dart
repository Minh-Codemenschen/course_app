import 'package:flutter/material.dart';
import 'dart:io';
import 'services/file_service.dart';
import 'widgets/file_handler.dart';

class DebugFileTest extends StatefulWidget {
  const DebugFileTest({Key? key}) : super(key: key);

  @override
  State<DebugFileTest> createState() => _DebugFileTestState();
}

class _DebugFileTestState extends State<DebugFileTest> {
  String _basePath = '';
  String _testResults = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBasePath();
  }

  Future<void> _loadBasePath() async {
    setState(() => _isLoading = true);
    try {
      final path = await FileService.getBasePath();
      setState(() {
        _basePath = path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _basePath = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFilePaths() async {
    setState(() => _isLoading = true);
    
    final testFiles = [
      'App/Lektion_1/Lektion_1.pdf',
      'App/Lektion_1/Tab 1_1 - Grußformeln und Befinden - informell.mp3',
      'App/Lektion_2/Lektion_2.pdf',
    ];

    String results = 'File Path Tests:\n\n';
    
    for (String filePath in testFiles) {
      try {
        final exists = await FileService.fileExists(filePath);
        final fullPath = await FileService.getFilePath(filePath);
        
        results += 'File: $filePath\n';
        results += 'Exists: $exists\n';
        results += 'Full Path: ${fullPath ?? 'null'}\n';
        results += '---\n';
      } catch (e) {
        results += 'File: $filePath\n';
        results += 'Error: $e\n';
        results += '---\n';
      }
    }

    setState(() {
      _testResults = results;
      _isLoading = false;
    });
  }

  Future<void> _testPlatformInfo() async {
    final info = FileHandler.getPlatformFileAccessInfo();
    setState(() {
      _testResults = 'Platform Info:\n\n$info';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Service Debug'),
        backgroundColor: const Color(0xFF3b3ec3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Base Path:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      SelectableText(
                        _basePath,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testFilePaths,
                  child: const Text('Test File Paths'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testPlatformInfo,
                  child: const Text('Platform Info'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _testResults.isEmpty ? 'No test results yet' : _testResults,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 