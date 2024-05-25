import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/View%20Model/profile_page_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(userId: userId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 65, 152, 223),
          title: Text('Profilim'),
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.0),
                        Center(
                          child: GestureDetector(
                            onTap: viewModel.pickImage,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: viewModel.profileImageUrl != null
                                  ? NetworkImage(viewModel.profileImageUrl!)
                                  : viewModel.profileImage != null
                                      ? FileImage(viewModel.profileImage!)
                                          as ImageProvider
                                      : AssetImage(
                                          'assets/default_profile.png'),
                              child: viewModel.profileImageUrl == null &&
                                      viewModel.profileImage == null
                                  ? Icon(Icons.add_a_photo,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 40.0),
                        Text(
                          '${userData['firstName']} ${userData['lastName']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          userData['email'],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30.0),
                        ElevatedButton(
                          onPressed: () => viewModel.signOut(context),
                          child: Text('Çıkış Yap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 65, 152, 223),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
