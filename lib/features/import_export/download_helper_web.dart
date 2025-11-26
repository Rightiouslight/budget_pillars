import 'dart:html' as html;
import 'dart:typed_data';

/// Download a file with the given name and bytes (web implementation)
void downloadFile(String filename, Uint8List bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
