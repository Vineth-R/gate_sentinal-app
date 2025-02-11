import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Check if a user exists in Firestore
  Future<bool> checkUserExists(String userId) async {
    DocumentSnapshot doc = await firestore.collection("User").doc(userId).get();
    return doc.exists;
  }

  /// Add user to Firestore (Sign-Up)
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    await firestore.collection("User").doc(userId).set(userInfoMap);
  }
}
