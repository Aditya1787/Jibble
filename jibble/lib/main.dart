import 'package:flutter/material.dart';

void main() {
  runApp(const ImageTestApp());
}

class ImageTestApp extends StatelessWidget {
  const ImageTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ImageTestHome(),
    );
  }
}

class ImageTestHome extends StatelessWidget {
  const ImageTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Testing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NORMAL IMAGE
            const Text(
              "Normal Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/post1.png',
              height: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 30),

            // CIRCULAR PROFILE IMAGE
            const Text(
              "Circular Profile Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ),

            const SizedBox(height: 30),

            // CARD IMAGE (SOCIAL POST STYLE)
            const Text(
              "Post Card Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/post2.png',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
