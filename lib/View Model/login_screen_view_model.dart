import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/View/main_screen.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loginFailed = false;
  String errorMessage = '';

  Future<void> login(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception("User data is null");
      }

      String firstName = userData['firstName'];
      String lastName = userData['lastName'];
      String userId = userCredential.user!.uid;
      String? userProfileUrl = userData.containsKey('profileImageUrl')
          ? userData['profileImageUrl']
          : null;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            firstName: firstName,
            lastName: lastName,
            userId: userId,
            userProfileUrl: userProfileUrl ?? '',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      loginFailed = true;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided for that user.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
          break;
      }
      notifyListeners();
    } catch (e) {
      loginFailed = true;
      errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      print('Login error: $e');
    }
  }
}
