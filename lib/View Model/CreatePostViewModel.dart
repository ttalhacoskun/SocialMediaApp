import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/Model/model.dart';

class CreatePostViewModel extends ChangeNotifier {
  final String userName;
  final String userProfileUrl;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController headerController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<File> imageFiles = [];
  bool isLoading = false;

  CreatePostViewModel({
    required this.userName,
    required this.userProfileUrl,
  });

  Future<void> pickImages(BuildContext context) async {
    if (imageFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('En fazla 3 fotoğraf seçebilirsiniz')),
      );
      return;
    }

    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      imageFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
      if (imageFiles.length > 3) {
        imageFiles = imageFiles.sublist(0, 3);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('En fazla 3 fotoğraf seçebilirsiniz')),
        );
      }
      notifyListeners();
    }
  }

  Future<List<String>> _uploadImages(List<File> files) async {
    List<String> downloadUrls = [];
    for (File file in files) {
      String fileName = file.path.split('/').last;
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> createPost(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();

      try {
        List<String> imageUrls = await _uploadImages(imageFiles);
        final newPost = Post(
          date: DateTime.now().toString(),
          header: headerController.text,
          body: bodyController.text,
          imageFiles: imageUrls,
          comments: [],
          likes: 0,
          likedBy: [],
          userName: userName,
          userProfileUrl: userProfileUrl,
        );

        // Firestore'a yeni gönderiyi ekleyin ve id'yi atayın
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('posts')
            .add(newPost.toJson());
        newPost.id = docRef.id;
        await docRef.update({'id': newPost.id});

        if (context.mounted) {
          Navigator.pop(context, newPost);
        }
      } catch (e) {
        print(e); // Hata durumunu yönet
      } finally {
        if (context.mounted) {
          isLoading = false;
          notifyListeners();
        }
      }
    }
  }
}
