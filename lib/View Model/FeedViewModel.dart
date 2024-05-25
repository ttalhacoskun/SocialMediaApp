import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/Model/model.dart';

class FeedViewModel extends ChangeNotifier {
  final String firstName;
  final String lastName;
  final String userId;
  final String userProfileUrl;

  List<Post> posts = [];
  bool isLoading = true;

  FeedViewModel({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userProfileUrl,
  }) {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      posts = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        var post = Post.fromJson(data);
        post.id = doc.id;
        return post;
      }).toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> likePost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likedBy': FieldValue.arrayUnion([userId]),
      'likes': FieldValue.increment(1),
    });
    post.likedBy.add(userId);
    post.likes++;
    notifyListeners();
  }
}
