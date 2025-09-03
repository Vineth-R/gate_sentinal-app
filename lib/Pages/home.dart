import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/profilepage.dart';
import 'package:gate_sentinal/Pages/camerafeed.dart';
import 'package:gate_sentinal/Pages/fingerprintlogs.dart';
import 'package:gate_sentinal/Pages/fingerprintsettings.dart';
import 'package:gate_sentinal/Pages/videorecordings.dart';
import 'package:gate_sentinal/Services/gate_control_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  final GateControlService _gateControlService = GateControlService();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            height: 150 + MediaQuery.of(context).padding.top,
            color: Colors.white,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 105),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset('assets/image1.jpeg', fit: BoxFit.contain),
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
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 3,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profilepage(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!) as ImageProvider<Object>
                                  : null,
                              backgroundColor: Colors.grey,
                              radius: 20,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person, size: 30, color: Colors.black)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Main content area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF333333).withAlpha(235),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 50,
                      ),
                      child: Column(
                        children: [
                          // Grid for Camera and Gate Lock buttons
                          SizedBox(
                            height: 200, // Increased from 120 to 160
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 1.1,
                              children: [
                                _buildButton(
                                  iconPath: 'assets/camera.jpeg',
                                  label: 'Camera',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Camerafeed()),
                                    );
                                    print('Camera pressed');
                                  },
                                ),
                                _buildButton(
                                  iconPath: 'assets/lock.jpeg',
                                  label: 'Gate Lock',
                                  onPressed: () async {
                                    try {
                                      await _gateControlService.sendUnlockCommand();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Gate unlock command sent successfully!'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to send unlock command: $e'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    }
                                    print('Gate lock pressed');
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          // List of text buttons
                          _buildTextButton(
                            label: 'Fingerprint Settings',
                            onPressed: () {
                              print('Fingerprint Settings pressed');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FingerprintSettings(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildTextButton(
                            label: 'Motion Logs',
                            onPressed: () {
                              print('Motion Logs pressed');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Fingerprintlogs(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildTextButton(
                            label: 'Video Recordings',
                            onPressed: () {
                              print('Video Recordings pressed');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Videorecordings(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Text-Only Button Builder
  Widget _buildTextButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 2,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: GoogleFonts.amiko(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Icon Button Builder
  Widget _buildButton({
    required String iconPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          elevation: 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: Image.asset(
                iconPath,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              flex: 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiko(
                  color: Colors.black,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}