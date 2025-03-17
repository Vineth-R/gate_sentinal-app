import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FingerprintSettings extends StatefulWidget {
  const FingerprintSettings({super.key});

  @override
  _FingerprintSettingsState createState() => _FingerprintSettingsState();
}

class _FingerprintSettingsState extends State<FingerprintSettings> {
  String username = "Loading...";
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user signed in");
      return;
    }
    print("Fetching username for UID: ${user.uid}");

    try {
      DataSnapshot snapshot = await _database.child("users/${user.uid}/name").get();
      if (snapshot.exists) {
        setState(() {
          username = snapshot.value.toString();
        });
      } else {
        setState(() {
          username = user.displayName ?? 'Unknown';
        });
      }
    } catch (error) {
      print("Failed to fetch username: $error");
      setState(() {
        username = 'Error';
      });
    }
  }

  Future<int> getNextAvailableFingerprintId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 1;

    DataSnapshot snapshot = await _database.child("users/${user.uid}/Fingerprints").get();
    if (!snapshot.exists || snapshot.value == null) return 1;

    print("Data type of snapshot.value: ${snapshot.value.runtimeType}");
    if (snapshot.value is Map) {
      Map<dynamic, dynamic> fingerprints = snapshot.value as Map<dynamic, dynamic>;
      List<int> existingIds = fingerprints.keys.map((key) => int.parse(key)).toList();
      existingIds.sort();

      for (int i = 1; i <= existingIds.length + 1; i++) {
        if (!existingIds.contains(i)) {
          return i; // Return the first missing ID
        }
      }
      return existingIds.length + 1;
    } else if (snapshot.value is List) {
      List<dynamic> fingerprints = snapshot.value as List<dynamic>;
      List<int> existingIds = [];
      for (int i = 0; i < fingerprints.length; i++) {
        if (fingerprints[i] != null) {
          existingIds.add(i + 1); // Assuming list index + 1 as fingerprintId
        }
      }
      existingIds.sort();

      for (int i = 1; i <= existingIds.length + 1; i++) {
        if (!existingIds.contains(i)) {
          return i; // Return the first missing ID
        }
      }
      return existingIds.length + 1;
    } else {
      print("Unexpected data type: ${snapshot.value.runtimeType}");
      return 1;
    }
  }

  void triggerFingerprintAction(String action, int fingerprintId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user signed in");
      return;
    }

    try {
      await _database.child("fingerprintCommands/${user.uid}").set({
        "uid": user.uid,
        "action": action, // "enroll" or "delete"
        "fingerprintId": fingerprintId,
        "timestamp": ServerValue.timestamp,
      });

      print("Command sent: $action Fingerprint ID $fingerprintId");
    } catch (error) {
      print("Failed to send command: $error");
    }
  }

  Future<void> confirmDelete(int fingerprintId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this fingerprint?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              triggerFingerprintAction("delete", fingerprintId);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
              onPressed: () async {
                int nextId = await getNextAvailableFingerprintId();
                triggerFingerprintAction("enroll", nextId);
              },
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
              child: StreamBuilder<DatabaseEvent>(
                stream: _database.child("users/${user?.uid}/Fingerprints").onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  DataSnapshot data = snapshot.data!.snapshot;
                  print("Data type of data.value: ${data.value.runtimeType}");
                  print("Data value: ${data.value}");
                  if (!data.exists) {
                    return const Center(
                      child: Text(
                        "No fingerprints enrolled yet",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (data.value is Map) {
                    Map<dynamic, dynamic> fingerprints = data.value as Map<dynamic, dynamic>;
                    return ListView.builder(
                      itemCount: fingerprints.length,
                      itemBuilder: (context, index) {
                        String key = fingerprints.keys.elementAt(index);
                        int fingerprintId = int.parse(key);
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
                                onPressed: () => confirmDelete(fingerprintId),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (data.value is List) {
                    List<dynamic> fingerprints = data.value as List<dynamic>;
                    return ListView.builder(
                      itemCount: fingerprints.length,
                      itemBuilder: (context, index) {
                        if (fingerprints[index] != null) {
                          int fingerprintId = index + 1; // Assuming list index + 1 as fingerprintId
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
                                  onPressed: () => confirmDelete(fingerprintId),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Unexpected data type",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}