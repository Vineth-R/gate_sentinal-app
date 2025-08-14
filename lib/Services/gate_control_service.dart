import 'package:firebase_database/firebase_database.dart';

class GateControlService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  /// Send unlock command to the gate
  Future<void> sendUnlockCommand() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _databaseReference.child("gateControl").set({
        "command": "unlock",
        "status": "pending",
        "lastUpdated": timestamp,
      });
      
      print("✅ Unlock command sent");
    } catch (e) {
      print("❌ Error sending unlock command: $e");
      rethrow;
    }
  }

  /// Send lock command to the gate
  Future<void> sendLockCommand() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _databaseReference.child("gateControl").set({
        "command": "lock",
        "status": "pending",
        "lastUpdated": timestamp,
      });
      
      print("✅ Lock command sent");
    } catch (e) {
      print("❌ Error sending lock command: $e");
      rethrow;
    }
  }

  /// Listen to gate control status changes
  Stream<DatabaseEvent> getGateControlStream() {
    return _databaseReference.child("gateControl").onValue;
  }

  /// Get current gate control status
  Future<Map<String, dynamic>?> getCurrentGateStatus() async {
    try {
      final snapshot = await _databaseReference.child("gateControl").get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print("❌ Error getting gate status: $e");
      return null;
    }
  }
}
