import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ImagePickerTestApp());
}

class ImagePickerTestApp extends StatelessWidget {
  const ImagePickerTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImagePickerTestHome(),
    );
  }
}

class ImagePickerTestHome extends StatefulWidget {
  const ImagePickerTestHome({super.key});

  @override
  State<ImagePickerTestHome> createState() => _ImagePickerTestHomeState();
}

class _ImagePickerTestHomeState extends State<ImagePickerTestHome> {
  File? image;
  final ImagePicker picker = ImagePicker();

  Future<void> pickFromGallery() async {
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? picked =
        await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Picker Test")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          image == null
              ? const Text("No Image Selected")
              : Image.file(image!, height: 250),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: pickFromGallery,
            child: const Text("Pick From Gallery"),
          ),

          ElevatedButton(
            onPressed: pickFromCamera,
            child: const Text("Open Camera"),
          ),
        ],
      ),
    );
  }
}
