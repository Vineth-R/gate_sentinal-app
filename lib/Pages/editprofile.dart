import 'dart:io'; // Import for File handling
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  XFile? _imageFile;
  final ImagePicker picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        nameController.text = user!.displayName ?? "";
      });
    }
  }

  Future<void> _updateName() async {
    if (user != null) {
      String newName = nameController.text.trim();
      if (newName.isNotEmpty) {
        try {
          await user!.updateDisplayName(newName);
          await user!.reload();
          user = FirebaseAuth.instance.currentUser;

          // Update Firestore
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(
            {'name': newName},
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile name updated.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name cannot be empty'), backgroundColor: Colors.orange),
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
      body:Expanded(
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
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                  backgroundColor: Colors.grey,
                  radius: 70,
                  child: _imageFile == null && user?.photoURL == null
                      ? const Icon(Icons.person, size: 50, color: Colors.black)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => bottomSheet(),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      radius: 18,
                      child: const Icon(Icons.camera, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20.0),
         child: Column( children: [ const SizedBox(height: 25),
          TextFormField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
        labelText: 'Enter New Name',
        labelStyle: const TextStyle(color: Colors.white),
        hintText: 'New Name',
        hintStyle: const TextStyle(color: Colors.white),
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
          const SizedBox(height: 10),
         SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Update Name', style: TextStyle(fontSize: 18.0)),
                ),
              ),
        ]
        )
        )
      ],
      ),
      )
      )
      );
  }

  /// **Bottom Sheet Function**
  Widget bottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Choose Profile Photo", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.camera, color: Colors.black),
                onPressed: () => takePhoto(ImageSource.camera),
                label: const Text("Camera", style: TextStyle(color: Colors.black)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.image, color: Colors.black),
                onPressed: () => takePhoto(ImageSource.gallery),
                label: const Text("Gallery", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }
}

// /// **Custom AppBar Shape**
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
