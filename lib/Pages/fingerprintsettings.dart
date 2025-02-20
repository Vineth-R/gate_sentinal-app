import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Fingerprintsettings extends StatelessWidget {
  const Fingerprintsettings({super.key});

  // Function to trigger the fingerprint action
  void triggerFingerprintAction(String action, int fingerprintId) {
    final user = FirebaseAuth.instance.currentUser; // Get signed-in user
    if (user == null) {
      print("No user signed in");
      return;
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user.uid}/fingerprint_action");

    ref.set({
      "action": action, // "enroll" or "delete"
      "fingerprint_id": fingerprintId, // Unique fingerprint ID
    }).then((_) {
      print("Fingerprint action '$action' triggered successfully!");
    }).catchError((error) {
      print("Failed to trigger fingerprint action: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10), // Space from the left side
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 50), // Space between back button and logo
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      'assets/image1.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8), // Space between logo and title
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
      body: Expanded(
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
          decoration: BoxDecoration(
            color: Color(0xFF333333).withAlpha(235),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Fingerprint settings page!',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 40),
                // Enroll Button
                ElevatedButton(
                  onPressed: () {
                    triggerFingerprintAction("enroll", 1); // Change 1 to dynamic ID
                  },
                  child: Text('Enroll Fingerprint'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    // primary: Colors.green, // Green for enroll
                    // onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Delete Button
                ElevatedButton(
                  onPressed: () {
                    triggerFingerprintAction("delete", 1); // Change 1 to dynamic ID
                  },
                  child: Text('Delete Fingerprint'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    // primary: Colors.red, // Red for delete
                    // onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
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
