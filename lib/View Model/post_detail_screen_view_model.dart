import 'package:flutter/material.dart';
import 'package:social_media/Model/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailViewModel extends ChangeNotifier {
  final Post post;
  final String firstName;
  final String lastName;
  final String userId;

  final TextEditingController commentController = TextEditingController();
  final Map<String, Map<String, String>> userProfiles = {};
  bool isLoading = false;

  PostDetailViewModel({
    required this.post,
    required this.firstName,
    required this.lastName,
    required this.userId,
  }) {
    _loadUserProfiles();
  }

  Future<void> _loadUserProfiles() async {
    for (var comment in post.comments) {
      if (!userProfiles.containsKey(comment.user)) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(comment.user)
            .get();
        if (userDoc.exists) {
          userProfiles[comment.user] = {
            'name': '${userDoc['firstName']} ${userDoc['lastName']}',
            'profileImageUrl': userDoc['profileImageUrl'] ?? '',
          };
          notifyListeners();
        }
      }
    }
  }

  Future<void> addComment(String text) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      Comment newComment = Comment(user: userId, commentText: text);

      await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
        'comments': FieldValue.arrayUnion([newComment.toJson()])
      });

      commentController.clear();
      post.comments.add(newComment);
      userProfiles[userId] = {
        'name': '$firstName $lastName',
        'profileImageUrl': '',
      };
      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost() async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likedBy': FieldValue.arrayUnion([userId]),
      'likes': FieldValue.increment(1),
    });
    post.likedBy.add(userId);
    post.likes++;
    notifyListeners();
  }

  bool isPostLiked() {
    return post.likedBy.contains(userId);
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.toLocal().year}-${dateTime.toLocal().month.toString().padLeft(2, '0')}-${dateTime.toLocal().day.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime dateTime) {
    return "${dateTime.toLocal().hour.toString().padLeft(2, '0')}:${dateTime.toLocal().minute.toString().padLeft(2, '0')}";
  }
}
