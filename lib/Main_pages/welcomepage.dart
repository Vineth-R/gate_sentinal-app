import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/loginpage.dart';
import 'package:google_fonts/google_fonts.dart';

class Welcomepage extends StatelessWidget {
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:  Color(0xB3B3B3B3).withAlpha(100), 
      body: Stack(
        children: [
          // White triangle in the body
          Positioned.fill(
            child: ClipPath(
              clipper: WhiteTriangleClipper(screenHeight),
              child: Container(color: Colors.white),
            ),
          ),

          // Black triangle overlay
          Positioned.fill(
            child: ClipPath(
              clipper: BlackTriangleClipper(screenHeight),
              child: Container(color: const Color.fromARGB(255, 34, 34, 34)),
            ),
          ),

          // App Logo & Title
          Positioned(
            top: screenHeight * 0.20, // Adjusted position
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/image1.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
                SizedBox(height: 10),
                Text(
                  "Gate Sentinel",
                  style: GoogleFonts.acme(
                    fontSize: 32, 
                    // fontWeight: FontWeight.bold, 
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Get Started Button
          Positioned(
            bottom: screenHeight * 0.10, 
            left: screenWidth * 0.25,
            right: screenWidth * 0.25,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context)=> const LoginPage())
                );
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Get Started", 
                style: 
                GoogleFonts.acme(
                  fontSize: 22
                  ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// White Triangle (Main Design)
class WhiteTriangleClipper extends CustomClipper<Path> {
  final double screenHeight;
  WhiteTriangleClipper(this.screenHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, screenHeight * 0.3);
    path.lineTo(size.width / 2, size.height * 0.65);
    path.lineTo(size.width, screenHeight * 0.3);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Black Triangle (Overlay)
class BlackTriangleClipper extends CustomClipper<Path> {
  final double screenHeight;
  BlackTriangleClipper(this.screenHeight);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, screenHeight*0.3);
    path.lineTo(size.width / 2, size.height * 0.65);
    path.lineTo(size.width,screenHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
