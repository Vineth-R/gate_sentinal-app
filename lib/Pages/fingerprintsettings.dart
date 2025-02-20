import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate_sentinal/Services/database.dart';
import 'package:google_fonts/google_fonts.dart';

class FingerprintSettings extends StatefulWidget {
  const FingerprintSettings({super.key});

  @override
  _FingerprintSettingsState createState() => _FingerprintSettingsState();
}

class _FingerprintSettingsState extends State<FingerprintSettings> {
  List<int> fingerprintIds = [];
   String username = "Loading..."; 

  void initState(){
    super.initState();
    fetchUserName();
    fetchFingerprints();
  }

 void fetchFingerprints() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Get fingerprints from Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("User")
          .doc(user.uid)
          .collection("Fingerprints")
          .get();
      setState(() {
        fingerprintIds = snapshot.docs.map((doc) => doc["fingerprintId"] as int).toList();
      });
    } catch (e) {
      print("Error fetching fingerprints: $e");
    }
  }
}
 void fetchUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("No user signed in");
    return;
  }

  try {
    // Fetch username from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (snapshot.exists) {
      print("User found in Firestore: ${snapshot.data()}");
      setState(() {
        username = snapshot['name'] ?? 'Unknown';  // Get name field from Firestore
      });
    } else {
      print("User document does not exist");
      setState(() {
        username = 'Unknown';
      });
    }
  } catch (error) {
    print("Failed to fetch username: $error");
    setState(() {
      username = 'Error';
    });
  }
}

 void triggerFingerprintAction(String action, int fingerprintId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("No user signed in");
    return;
  }

  if (action == "enroll") {
    await DatabaseMethods().addFingerprint(user.uid, fingerprintId);  // Use Firestore method
    setState(() {
      fingerprintIds.add(fingerprintId);
    });
  } else if (action == "delete") {
    await DatabaseMethods().removeFingerprint(user.uid, fingerprintId);  // Use Firestore method
    setState(() {
      fingerprintIds.remove(fingerprintId);
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 50),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      'assets/image1.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
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
      body: Container(
        padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF333333).withAlpha(235),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Fingerprint Settings',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 40),
            // Add Fingerprint Button
            ElevatedButton(
              onPressed: () => triggerFingerprintAction("enroll", fingerprintIds.length + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "+ Add Fingerprint",
                  style: GoogleFonts.amiko(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display Enrolled Fingerprints
            Expanded(
              child: ListView.builder(
                itemCount: fingerprintIds.length,
                itemBuilder: (context, index) {
                  int fingerprintId = fingerprintIds[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$username - $fingerprintId",
                          style: GoogleFonts.amiko(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () => triggerFingerprintAction("delete", fingerprintId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// // Custom AppBar Shape
// class CustomAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width / 2, size.height - 80);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
