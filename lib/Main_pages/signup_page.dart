import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/loginpage.dart';
import 'package:gate_sentinal/Pages/home.dart';
import 'package:gate_sentinal/Services/auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController fullnamecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = false;
  bool _showpassword = false;

  @override
  void dispose() {
    fullnamecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  Future<void> registration() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passwordcontroller.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          await user.updateDisplayName(fullnamecontroller.text.trim());


            await FirebaseDatabase.instance.ref().child("User").child(user.uid).set({
            "name": fullnamecontroller.text.trim(),
            "email": emailcontroller.text.trim(),
            "id": user.uid,
            "createdAt": DateTime.now().toIso8601String(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registered successfully', style: TextStyle(fontSize: 20.0)),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Registration failed';
        if (e.code == 'weak-password') {
          message = 'Password must be at least 6 characters long';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account with this email already exists';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black87,
            content: Text(message, style: const TextStyle(fontSize: 18.0)),
          ),
        );
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the processing of personal data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        // child: ClipPath(
          // clipper: CustomAppBarClipper(),
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
                      onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>LoginPage())),
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
        // padding: const EdgeInsets.all(20.0),
        flex: 7,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
          decoration: BoxDecoration(
            color: Color(0xFF333333).withAlpha(235), 
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
        child: Form(
          key: _formSignupKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(fullnamecontroller, 'Full Name', 'Enter Full Name'),
              const SizedBox(height: 25.0),
              _buildTextField(emailcontroller, 'Email', 'Enter Email'),
              const SizedBox(height: 25.0),
              _buildTextField(passwordcontroller, 'Password', 'Enter Password', isPassword: true),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Checkbox(
                    value: agreePersonalData,
                    onChanged: (bool? value) {
                      setState(() {
                        agreePersonalData = value ?? false;
                      });
                    },
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                  ),
                  const Text('I agree to the processing of ', style: TextStyle(color: Colors.white)),
                  const Text('Personal Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18.0)),
                ),
              ),
              const SizedBox(height: 25.0),
              buildSocialMediaIcons(),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    },
                    child: const Text(' Sign in', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
     )
      );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword? !_showpassword: false,
      obscuringCharacter: '*',
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isPassword
        ? IconButton(onPressed: (){
          setState(() {
            _showpassword = !_showpassword;
          });
        }, 
        icon: Icon(
                _showpassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              )):null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget buildSocialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => AuthMethods().signInWithGoogle(context),
          child: const Icon(Icons.email, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    // path.lineTo(size.width / 2, size.height - 80);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
