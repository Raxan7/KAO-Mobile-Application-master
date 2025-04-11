import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';  // For basename

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        // print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    // Replace with your PHP server URL
    String uploadUrl = 'http://192.168.22.177/hotel/hotelbooking/api/upload_image.php';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', 
        _image!.path, 
        filename: basename(_image!.path))
    );

    var response = await request.send();
    
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      // print("Everything is going great $responseBody");
      // print('Image uploaded successfully!');
    } else {
      // print('Image upload failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null ? Image.file(_image!) : const Text('No image selected.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _chooseImage,
              child: const Text('Select Image'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
