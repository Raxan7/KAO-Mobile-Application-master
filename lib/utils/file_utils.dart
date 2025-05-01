import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class FileUtils {
  static Future<String> getTemporaryFilePath(Uint8List bytes, String extension) async {
    if (kIsWeb) {
      // For web, we'll handle differently
      throw UnsupportedError('getTemporaryFilePath not supported on web');
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  }

  static Future<String> saveFileForUpload(dynamic fileData) async {
    if (fileData is File) {
      return fileData.path;
    } else if (fileData is Uint8List) {
      if (kIsWeb) {
        // For web, we'll upload directly from bytes
        throw UnsupportedError('Web upload needs special handling');
      } else {
        return await getTemporaryFilePath(fileData, 'jpg');
      }
    }
    throw ArgumentError('Unsupported file type');
  }
}