import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/loginpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Profilepage extends StatefulWidget { 
  const Profilepage({super.key});

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage>{

  User? user;
  String displayName = "User";

   @override
void initState() {
  super.initState(); // Ensure this is called first
  _getCurrentUser();
}


 void _getCurrentUser() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    setState(() {
      user = currentUser;
      displayName = currentUser.displayName ?? "No Name...";
    });

    if(currentUser.displayName == null || currentUser.displayName!.isEmpty){
      await _fetchNameFromFirestore(currentUser.uid);
    }
  }
}

Future<void> _fetchNameFromFirestore(String userId) async{
  DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if(userDoc.exists && userDoc['name'] != null){
          setState(() {
            displayName = userDoc['name'];
          });
        }
        else{
          displayName = 'No name set';
        }
}

void signOut(BuildContext context) async{
  try{
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, 
    MaterialPageRoute(builder: (context)=> LoginPage()));
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error signing out: $e"),
        backgroundColor: Colors.red,
      ),
    );
      }
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background Color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(175),
        child: ClipPath(
          clipper: CustomAppBarClipper(),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 10), // Space from the left side

                    // 🔹 Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28), // Color fixed to black
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(width: 50), // Space between back button and logo

                    // 🔹 Logo Image
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/image1.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(width: 8), // Space between logo and title

                    // 🔹 Title Text
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
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children:[ CircleAvatar(
                     backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!) as ImageProvider<Object>
                        // : const AssetImage('assets/default_avatar.png'),
                        :null,
                        backgroundColor: Colors.grey,
                      radius: 70,
                        child:user?.photoURL == null 
                        ?Icon(Icons.person, size: 50, color: Colors.black,)
                        :null,
                    ),
          ]
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
              displayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              ),
            ],
          ),
          // const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user?.email ?? "No Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              )

            ],
          ),

          const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()=> signOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Sign Out", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
      ],

      
        
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