import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  String? _profileImagePath;

  Future<void> _selectAndCropImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
      );

      if (croppedFile != null) {
        setState(() {
          _profileImagePath = croppedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Profile Picture'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _profileImagePath == null
                ? const CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/placeholder.png'),
                  )
                : CircleAvatar(
                    radius: 80,
                    backgroundImage: FileImage(
                      File(_profileImagePath!),
                    ),
                  ),
            const SizedBox(height: 16),
            const Text('Professional photos only', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectAndCropImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
