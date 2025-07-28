import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

// A more complete stub implementation for web platform
class WebFile {
  final String path;
  final String name;
  final int size;
  final Uint8List bytes;
  final DateTime lastModified;

  WebFile(this.path, {this.name = '', this.size = 0, required this.bytes})
      : lastModified = DateTime.now();

  // Create from html.File for web uploads
  factory WebFile.fromHtmlFile(html.File file) {
    return WebFile(file.name, name: file.name, size: file.size.toInt(), bytes: Uint8List(0));
  }

  // Mock exists() - always true since we're creating the file
  Future<bool> exists() async => true;

  // Mock stat() - returns basic file info
  Future<FileStat> stat() async => FileStat(
    FileSystemEntityType.file,
    size,
    lastModified,
    lastModified,
    lastModified,
  );

  // Read as bytes - returns the stored bytes
  Future<Uint8List> readAsBytes() async => bytes;

  // Mock write - just returns the same file
  Future<WebFile> writeAsBytes(List<int> bytes) async => this;

  // Mock delete - does nothing
  Future<void> delete() async {}

  // For compatibility with supabase upload
  Future<Uint8List> readAsBytesSync() async => bytes;

  // Additional method needed by some file operations
  String get absolutePath => path;
}

// Simplified FileStat implementation
class FileStat {
  final FileSystemEntityType type;
  final int size;
  final DateTime modified;
  final DateTime accessed;
  final DateTime changed;

  FileStat(
    this.type,
    this.size,
    this.modified,
    this.accessed,
    this.changed,
  );
}

// Enum to match dart:io
enum FileSystemEntityType {
  file,
  directory,
  link,
  notFound
}

// For compatibility with code that expects dart:io File
typedef File = WebFile;