import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ProfilePictureChanger extends StatefulWidget {
  const ProfilePictureChanger({Key? key}) : super(key: key);

  @override
  _ProfilePictureChangerState createState() => _ProfilePictureChangerState();
}

class _ProfilePictureChangerState extends State<ProfilePictureChanger> {
  File? selectedImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    
  }
  @override
  didChangeDependencies(){
loadProfileImage();
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      setState(() {
        selectedImage = file;
      });
      try {
        String fileName = path.basename(image.path);
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('profileimage/$fileName');

        await firebaseStorageRef.putFile(file);

        String downloadURL = await firebaseStorageRef.getDownloadURL();
        await _updateUserProfilePicture(downloadURL);
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image téléchargée avec succès: $downloadURL')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du téléchargement de l'image: $e")),
        );
      }
    }
  }

  Future<void> _updateUserProfilePicture(String downloadURL) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profilePicture': downloadURL,
    });
  }

  Future<void> loadProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDocument = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final imageUrl = userDocument.get('profilePicture');
        if (imageUrl != null) {
          setState(() {
            profileImageUrl = imageUrl;
          });
        }
      }
    } catch (error) {
      print('Error loading user profile image URL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changer la photo de profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : (profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : AssetImage('img/profile.jpg')) as ImageProvider,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickAndUploadImage(context),
              child: Text('Changer la photo de profil'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePictureChanger(),
  ));
}
