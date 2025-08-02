import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  List<String> debugInfo = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAssets();
  }

  Future<void> _checkAssets() async {
    setState(() {
      isLoading = true;
      debugInfo.clear();
    });

    try {
      // Test PDF file
      debugInfo.add('Testing PDF file...');
      try {
        final pdfBytes = await rootBundle.load('assets/App/Lektion_1/Lektion_1.pdf');
        debugInfo.add('✓ PDF loaded successfully: ${pdfBytes.lengthInBytes} bytes');
      } catch (e) {
        debugInfo.add('✗ PDF load failed: $e');
      }

      // Test audio file
      debugInfo.add('Testing audio file...');
      try {
        final audioBytes = await rootBundle.load('assets/App/Lektion_1/Tab 1_1 - Grußformeln und Befinden - informell.mp3');
        debugInfo.add('✓ Audio loaded successfully: ${audioBytes.lengthInBytes} bytes');
      } catch (e) {
        debugInfo.add('✗ Audio load failed: $e');
      }

      // Check temp directory
      if (!kIsWeb) {
        debugInfo.add('Checking temp directory...');
        try {
          final tempDir = await Directory.systemTemp.createTemp();
          debugInfo.add('✓ Temp directory created: ${tempDir.path}');
          
          // Test file creation
          final testFile = File('${tempDir.path}/test.txt');
          await testFile.writeAsString('test');
          debugInfo.add('✓ File creation test passed');
          await testFile.delete();
        } catch (e) {
          debugInfo.add('✗ Temp directory/file test failed: $e');
        }
      }

      // Platform info
      debugInfo.add('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
      debugInfo.add('Platform version: ${kIsWeb ? 'N/A' : Platform.operatingSystemVersion}');

    } catch (e) {
      debugInfo.add('General error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAssets,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: debugInfo.length,
              itemBuilder: (context, index) {
                final info = debugInfo[index];
                final isError = info.startsWith('✗');
                final isSuccess = info.startsWith('✓');
                
                return ListTile(
                  title: Text(
                    info,
                    style: TextStyle(
                      color: isError ? Colors.red : (isSuccess ? Colors.green : Colors.black),
                      fontWeight: isError || isSuccess ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
    );
  }
} 