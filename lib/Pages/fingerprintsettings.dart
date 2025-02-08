import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Fingerprintsettings extends StatelessWidget {
  const Fingerprintsettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white, // Background Color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        // child: ClipPath(
        //   clipper: CustomAppBarClipper(),
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
        // ),
      ),
      body: Expanded(
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
          decoration: BoxDecoration(
            color: Color(0xFF333333).withAlpha(235), 
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40)
            )
          ),
        child: const Center(
        child: Text(
          'Video Recordings page!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      )
      )
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
