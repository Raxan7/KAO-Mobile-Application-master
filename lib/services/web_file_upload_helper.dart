// Web-specific implementation for handling file uploads
import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class WebFileUploadHelper {
  /// Fetch contents of a blob URL
  static Future<Uint8List> fetchBlobUrl(String blobUrl) async {
    final completer = Completer<Uint8List>();
    final xhr = html.HttpRequest();
    
    xhr.open('GET', blobUrl);
    xhr.responseType = 'arraybuffer';
    
    xhr.onLoad.listen((_) {
      final bytes = Uint8List.fromList(xhr.response as List<int>);
      completer.complete(bytes);
    });
    
    xhr.onError.listen((event) {
      completer.completeError('Failed to fetch blob: $event');
    });
    
    xhr.send();
    
    return completer.future;
  }
  
  /// Create a multipart file from a blob URL
  static Future<http.MultipartFile> createMultipartFileFromBlobUrl(
    String blobUrl, 
    String fieldName,
    String contentType,
    String? filename
  ) async {
    final bytes = await fetchBlobUrl(blobUrl);
    
    return http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: filename ?? 'file_${DateTime.now().millisecondsSinceEpoch}',
      contentType: MediaType.parse(contentType)
    );
  }
  
  /// Create a FormData directly from a blob URL
  /// This is an alternative approach that might work better in some browsers
  static html.FormData createFormDataWithBlob(
    String blobUrl,
    String fieldName, 
    Map<String, String> fields
  ) {
    final formData = html.FormData();
    
    // Create an XHR to fetch the blob
    final xhr = html.HttpRequest();
    xhr.open('GET', blobUrl, async: false); // Synchronous for simplicity
    xhr.responseType = 'blob';
    xhr.send();
    
    // Add the blob to form data
    if (xhr.response != null) {
      final blob = xhr.response as html.Blob;
      formData.appendBlob(fieldName, blob);
    }
    
    // Add other fields
    fields.forEach((key, value) {
      formData.append(key, value);
    });
    
    return formData;
  }
}
