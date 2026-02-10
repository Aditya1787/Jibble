import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FontTestApp());
}

class FontTestApp extends StatelessWidget {
  const FontTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Font Tester',
      home: const FontTestHome(),
    );
  }
}

class FontTestHome extends StatelessWidget {
  const FontTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Font Testing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // POPPINS
            Text(
              "Poppins Font",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This is how posts, captions, and UI text will look using Poppins.",
              style: GoogleFonts.poppins(fontSize: 16),
            ),

            const Divider(height: 40),

            // INTER
            Text(
              "Inter Font",
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Inter is clean and perfect for feeds, comments, and long reading text.",
              style: GoogleFonts.inter(fontSize: 16),
            ),

            const Divider(height: 40),

            // DANCING SCRIPT
            Text(
              "Dancing Script",
              style: GoogleFonts.dancingScript(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Best for usernames, quotes, bios, and artistic content.",
              style: GoogleFonts.dancingScript(fontSize: 18),
            ),

            const SizedBox(height: 40),

            // BUTTON TEST
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Post Now",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
