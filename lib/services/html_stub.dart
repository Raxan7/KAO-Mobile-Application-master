// Stub HTML implementation for mobile platforms where universal_html isn't available

// HttpRequest stub for XHR
class HttpRequest {
  // Properties
  String responseType = '';
  dynamic response;
  
  // Methods
  void open(String method, String url) {}
  void send() {}
  
  // Event handlers
  Stream<dynamic> get onLoad => const Stream.empty();
  Stream<dynamic> get onError => const Stream.empty();
}

// Window stub
final window = Window();

class Window {
  final localStorage = <String, dynamic>{};
}

// Stub FileReader class
class FileReader {
  dynamic result;
  
  Stream<dynamic> get onLoad => const Stream.empty();
  Stream<dynamic> get onError => const Stream.empty();
  
  void readAsArrayBuffer(dynamic file) {}
}
