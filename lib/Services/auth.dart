import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gate_sentinal/Pages/home.dart';
import 'package:gate_sentinal/Services/database.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In was cancelled.")),
        );
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid,
        };

        // Store user data in Firestore
        await DatabaseMethods().addUser(userDetails.uid, userInfoMap);

        // Navigate to Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
    }
  }

  Future<void> signOutGoogle(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signed out successfully!")),
    );
  }
}
