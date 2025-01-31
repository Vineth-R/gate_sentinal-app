import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/loginpage.dart';
import 'package:gate_sentinal/Pages/home.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formSignupKey = GlobalKey<FormState>(); // ✅ Corrected key name
  bool agreePersonalData = false; // ✅ Initialized the variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Custom AppBar
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
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
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
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formSignupKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name Field
              _buildTextField('Full Name', 'Enter Full Name'),
              const SizedBox(height: 25.0),
              // Email Field
              _buildTextField('Email', 'Enter Email'),
              const SizedBox(height: 25.0),
              // Password Field
              _buildTextField('Password', 'Enter Password', isPassword: true),
              const SizedBox(height: 20.0),
              
              // Agreement Checkbox
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
                  const Text(
                    'I agree to the processing of ',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Text(
                    'Personal Data',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                    } else if (!agreePersonalData) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please agree to the processing of personal data')),
                      );
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 25.0),

              // Sign Up with Social Media
              _buildSocialMediaRow(),

              const SizedBox(height: 25.0),

              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(' Sign in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(String label, String hint, {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      obscuringCharacter: '*',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // Helper function for social media icons
  Widget _buildSocialMediaRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(Icons.facebook, color: Colors.white, size: 30),
        Icon(Icons.email, color: Colors.white, size: 30),
        Icon(Icons.apple, color: Colors.white, size: 30),
      ],
    );
  }
}

// Custom AppBar Shape
class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(0, size.height)
      ..lineTo(size.width / 2, size.height - 80)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
