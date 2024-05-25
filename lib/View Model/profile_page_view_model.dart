import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/View/login_screen.dart';

class ProfileViewModel extends ChangeNotifier {
  final String userId;
  File? _profileImage;
  String? _profileImageUrl;

  ProfileViewModel({required this.userId}) {
    _loadUserProfile();
  }

  File? get profileImage => _profileImage;
  String? get profileImageUrl => _profileImageUrl;

  Future<void> _loadUserProfile() async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      _profileImageUrl = userDoc.data()?['profileImageUrl'];
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      notifyListeners();
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      String fileName = 'profile_$userId.png';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('profileImages/$fileName')
          .putFile(_profileImage!);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      _profileImageUrl = downloadUrl;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profileImageUrl': downloadUrl});
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
