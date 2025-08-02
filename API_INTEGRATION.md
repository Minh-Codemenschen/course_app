# API Integration for Course App

## Overview

This Flutter app now includes API integration to fetch course lessons from the remote server at `https://codemenschen.at/course_app/` and download the associated files (PDFs and audio files).

## Features

### 1. API Data Fetching
- Fetches lesson data from the remote API
- Displays all available lessons with their associated files
- Handles network errors and provides user-friendly error messages

### 2. File Download System
- Downloads PDF files for each lesson
- Downloads all audio files associated with each lesson
- Creates organized folder structure on device storage
- Shows download progress with visual indicators

### 3. Download Management
- Individual lesson download buttons
- Bulk download all lessons option
- Download status tracking (downloaded/not downloaded)
- Progress indicators during download

## API Structure

The API returns JSON data in the following format:

```json
{
  "lessons": [
    {
      "name": "Lektion 1",
      "pdf": "App/Lektion_1/Lektion_1.pdf",
      "audio": [
        "App/Lektion_1/Audio_E1_1.mp3",
        "App/Lektion_1/Tab 1_1 - Grußformeln und Befinden - informell.mp3"
      ]
    }
  ],
  "total_lessons": 20
}
```

## File Structure

Downloaded files are organized in the following structure on the device:

```
/storage/emulated/0/Download/course_app/
├── App/
│   ├── Lektion_1/
│   │   ├── Lektion_1.pdf
│   │   ├── Audio_E1_1.mp3
│   │   └── Tab 1_1 - Grußformeln und Befinden - informell.mp3
│   ├── Lektion_2/
│   └── ...
```

## Usage

### Accessing the API Features

1. Open the app and navigate to the main screen
2. Click the "Download from API" button (green button with cloud download icon)
3. This will open the API Lessons page where you can:
   - View all available lessons from the API
   - Download individual lessons
   - Download all lessons at once

### Downloading Files

1. **Individual Lesson Download:**
   - Click the "Download Lesson" button on any lesson card
   - The download will start with progress indication
   - Files will be saved to the device's download folder

2. **Bulk Download:**
   - Click the download icon in the app bar
   - All lessons will be downloaded sequentially
   - Progress is shown in a dialog

### File Access

Downloaded files can be accessed:
- **Android:** In the Downloads folder under `course_app/`
- **iOS:** In the app's documents directory
- Files maintain their original folder structure from the API

## Technical Implementation

### Dependencies Added

```yaml
dependencies:
  http: ^1.1.0
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
```

### Key Components

1. **ApiService** (`lib/services/api_service.dart`)
   - Handles API communication
   - Manages file downloads
   - Provides local file path utilities

2. **Lesson Model** (`lib/models/lesson.dart`)
   - Data structure for lesson information
   - JSON serialization/deserialization

3. **DownloadManager Widget** (`lib/widgets/download_manager.dart`)
   - UI component for individual lesson downloads
   - Progress tracking and status display

4. **ApiLessonsPage** (`lib/pages/api_lessons_page.dart`)
   - Main page for displaying API lessons
   - Bulk download functionality

### Permissions

The app requires the following permissions:

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS (Info.plist):**
Storage permissions are handled automatically by the path_provider plugin.

## Error Handling

The app handles various error scenarios:

1. **Network Errors:**
   - No internet connection
   - Server unavailable
   - Timeout errors

2. **File Download Errors:**
   - File not found on server (404)
   - Storage permission denied
   - Insufficient storage space

3. **API Errors:**
   - Invalid response format
   - Server errors (5xx)

## Future Enhancements

Potential improvements for the API integration:

1. **Offline Support:**
   - Cache downloaded lessons locally
   - Sync when connection is restored

2. **Background Downloads:**
   - Download files in background
   - Notification when downloads complete

3. **Download Queue:**
   - Manage multiple downloads
   - Pause/resume functionality

4. **File Management:**
   - Delete downloaded files
   - View download history
   - Storage usage statistics

## Troubleshooting

### Common Issues

1. **Download Fails:**
   - Check internet connection
   - Verify storage permissions
   - Ensure sufficient storage space

2. **Files Not Found:**
   - Verify API endpoint is accessible
   - Check file paths in API response
   - Ensure server files exist

3. **Permission Errors:**
   - Grant storage permissions manually
   - Restart app after granting permissions

### Debug Information

Enable debug mode to see detailed error messages and download progress in the console logs. 