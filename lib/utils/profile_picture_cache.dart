import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Downloads a profile picture from URL and converts it to base64
Future<String?> downloadAndCacheProfilePicture(String? photoURL) async {
  if (photoURL == null || photoURL.isEmpty) {
    return null;
  }

  try {
    final response = await http.get(Uri.parse(photoURL));
    
    if (response.statusCode == 200) {
      // Convert to base64
      final base64String = base64Encode(response.bodyBytes);
      return base64String;
    } else {
      print('Failed to download profile picture: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error downloading profile picture: $e');
    return null;
  }
}

/// Decodes base64 profile picture to Uint8List for display
Uint8List? decodeProfilePicture(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    return null;
  }

  try {
    return base64Decode(base64String);
  } catch (e) {
    print('Error decoding profile picture: $e');
    return null;
  }
}
