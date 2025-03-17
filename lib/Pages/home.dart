import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/profilepage.dart';
import 'package:gate_sentinal/Pages/camerafeed.dart';
import 'package:gate_sentinal/Pages/fingerprintlogs.dart';
import 'package:gate_sentinal/Pages/fingerprintsettings.dart';
import 'package:gate_sentinal/Pages/videorecordings.dart';
import 'package:gate_sentinal/Pages/displaynotices.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

 @override
void initState() {
  super.initState(); // Ensure this is called first
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
      backgroundColor: Colors.white, // Background Color
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
                    // const SizedBox(width: 20),
                    
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
                    Column(children: [
                    const SizedBox(width:100, height: 50,),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, // Change this to your desired border color
                          width: 3, // Adjust border width
                        ),
                      ),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, 
                        MaterialPageRoute(builder: 
                        (context)=> Profilepage())
                        );
                      },

                    child: CircleAvatar(
                     backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!) as ImageProvider<Object>
                        :null,
                        backgroundColor: Colors.grey,
                      radius: 20,
                        child:user?.photoURL == null 
                        ?Icon(Icons.person, size: 30, color: Colors.black,)
                        :null,
                    ),
                    ),),
                    SizedBox(height: 100)]
                    
                    )]
                ),
              ],
            ),
          ),
        // ),
      ),
      body: Expanded(
        // padding: const EdgeInsets.all(50.0), // Adjust padding for consistent layout
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 50.0),
          decoration: BoxDecoration(
            color: Color(0xFF333333).withAlpha(235),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 40,
                crossAxisSpacing: 40,
                childAspectRatio: 1, // Keeps the buttons square
                children: [
                  _buildButton(
                    iconPath: 'assets/camera.jpeg',
                    label: 'Camera',
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context)=> const Camerafeed(),));
                      print('Camera pressed');
                    },
                  ),
                  _buildButton(
                    iconPath: 'assets/lock.jpeg',
                    label: 'Gate Lock',
                    onPressed: () {
                      print('Gate lock pressed');
                    },
                  ),
                  _buildButton(
                    iconPath: 'assets/mic_speaker.jpeg',
                    label: 'In-Door Mic and Speaker',
                    onPressed: () {
                      print('Indoor mic and speaker pressed');
                    },
                  ),
                  _buildButton(
                    iconPath: 'assets/mic_speaker.jpeg',
                    label: 'Out-Door Mic and Speaker',
                    onPressed: () {
                      print('Outdoor mic and speaker pressed');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Spacing between grid and text buttons

            ///Padding for Text Buttons
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: Column(
                children: [
                  _buildTextButton(
                    label: 'Fingerprint Settings',
                    onPressed: () {
                      print('Fingerprint Settings pressed');
                      Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => const FingerprintSettings(),
                      ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextButton(
                    label: 'Fingerprint Logs',
                    onPressed: () {
                      print('Fingerprint Logs pressed');
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
                      ),);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTextButton(
                    label: 'Display Notices',
                    onPressed: () {
                      print('Display Notices pressed');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Displaynotices()
                          ),);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
     ) );
  }

  //Text-Only Button Builder
  Widget _buildTextButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(700, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
    );
  }

  //Icon Button Builder
  Widget _buildButton({
    required String iconPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(110, 110),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 70,
            width: 70,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiko(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom AppBar Shape
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
