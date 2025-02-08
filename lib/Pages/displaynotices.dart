import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Displaynotices extends StatelessWidget {
  const Displaynotices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xB3B3B3B3).withAlpha(100), // Background Color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(175),
        child: ClipPath(
          clipper: CustomAppBarClipper(),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10), // Space from the left side

                    // 🔹 Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28), // Color fixed to black
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width: 50), // Space between back button and logo

                    // 🔹 Logo Image
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/image1.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(width: 8), // Space between logo and title

                    // 🔹 Title Text
                    Text(
                      "Gate Sentinel",
                      style: GoogleFonts.acme(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Video Recordings page!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

// Custom AppBar Shape
class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2, size.height - 80);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
