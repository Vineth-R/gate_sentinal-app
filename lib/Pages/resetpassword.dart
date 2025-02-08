import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  _ResetpasswordState createState() => _ResetpasswordState();
}
 User? user;
class _ResetpasswordState extends State<Resetpassword> {
  String email = "";
  final TextEditingController emailController = TextEditingController();


  void initState(){
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    final currentuser = FirebaseAuth.instance.currentUser;
    if(currentuser != null){
      setState(() {
        user = currentuser;
        emailController.text = user!.email??"";
      });
    }
  }


  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password Reset Email has been sent"),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No user found for that email."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white, // Background Color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(175),
        // child: ClipPath(
        //   clipper: CustomAppBarClipper(),
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 50),
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
                  ],
                ),
              ],
            ),
          ),
        // ),
      ),
      body: Expanded(
        // padding: const EdgeInsets.all(5.0),
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
          decoration: BoxDecoration(
            color: Color(0xFF333333).withAlpha(235), 
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40)
            )
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Password Recovery",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            const SizedBox(height: 10.0),
            const Text(
              "Enter your email",
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            const SizedBox(height: 25.0),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(20.0),
              child: Column(
                
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(Icons.email, color: Colors.white30),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),

                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                    child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          email = emailController.text;
                        });
                        resetPassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Send Email", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                    ),
                    ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
     )
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
