import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseMethods {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Check if a user exists in Firestore
  Future<bool> checkUserExists(String userId) async {
    DocumentSnapshot doc = await firestore.collection("User").doc(userId).get();
    return doc.exists;
  }

  /// Add user to FirebaseDatabase (Sign-Up)
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    await databaseReference.child("User").set(userInfoMap);
  }

  /// Add a fingerprint to the user's document
  Future<void> addFingerprint(String userId, int fingerprintId) async {
    try {
      // Create a collection for fingerprints under the user's document
      await firestore.collection("User").doc(userId).collection("Fingerprints").doc(fingerprintId.toString()).set({
        "fingerprintId": fingerprintId,
        "enrolledAt": Timestamp.now(),
      });
      print("Fingerprint enrolled: $fingerprintId");
    } catch (e) {
      print("Error adding fingerprint: $e");
    }
  }

  /// Remove a fingerprint from the user's document
  Future<void> removeFingerprint(String userId, int fingerprintId) async {
    try {
      // Remove the fingerprint from the Firestore collection
      await firestore.collection("User").doc(userId).collection("Fingerprints").doc(fingerprintId.toString()).delete();
      print("Fingerprint deleted: $fingerprintId");
    } catch (e) {
      print("Error removing fingerprint: $e");
    }
  }
}
