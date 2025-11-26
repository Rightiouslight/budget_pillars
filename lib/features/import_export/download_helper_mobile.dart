import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Download a file with the given name and bytes (mobile implementation)
Future<void> downloadFile(String filename, Uint8List bytes) async {
  try {
    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    // Write the file
    await file.writeAsBytes(bytes);

    // File saved to app documents directory
    // On mobile, files are saved to app-specific storage
    // Users can access them through file manager apps
  } catch (e) {
    throw Exception('Failed to save file: $e');
  }
}
