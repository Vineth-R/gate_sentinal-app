import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gate_sentinal/Main_pages/forgotpassword.dart';
import 'package:gate_sentinal/Main_pages/signup_page.dart';
import 'package:gate_sentinal/Main_pages/welcomepage.dart';
import 'package:gate_sentinal/Pages/home.dart';
import 'package:gate_sentinal/Services/auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();
  bool rememberPassword = false;
  bool _showpassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> userLogin() async {
    if (_formSignInKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successfully', style: TextStyle(fontSize: 20.0)),
            backgroundColor: Colors.green,
          ),);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        print("FirebaseAuthException Code: ${e.code}");
        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password.';
        } else if (e.code == "invalid-credential") {
          errorMessage = "The provided credential is invalid.";
        } else {
          errorMessage = "An unknown error occurred: ${e.message}";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: const TextStyle(fontSize: 18.0)),
            backgroundColor: Colors.red,
            
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                      onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context)=>Welcomepage())),
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
            color: Color(0xFF333333).withAlpha(235), // Much darker shade with higher opacity

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40)
            )
          ),
        child: Form(
          key: _formSignInKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(emailController, "Email", "Enter Email", false),
              const SizedBox(height: 25.0),
              buildTextField(passwordController, "Password", "Enter Password", true),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberPassword,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberPassword = value ?? false;
                          });
                        },
                        activeColor: Colors.black,
                        checkColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      const Text('Remember me', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPassword()),
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: userLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text("Sign In", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(thickness: 0.7, color: Colors.grey)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Sign in with', style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(thickness: 0.7, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 25.0),
              buildSocialMediaIcons(),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget buildTextField(TextEditingController controller, String label, String hint, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_showpassword : false,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
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
        suffixIcon: isPassword // Show eye icon only for password fields
          ? IconButton(
              icon: Icon(
                _showpassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _showpassword = !_showpassword;
                });
              },
            )
          : null,
    ),
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

// class CustomAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     // path.lineTo(size.width / 2, size.height - 80);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
