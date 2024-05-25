import 'package:flutter/material.dart';
import 'package:social_media/View/CreatePostView.dart';
import 'package:social_media/View/FeedView.dart';
import 'package:social_media/View/profile_page.dart';
import 'package:social_media/model/model.dart';

class MainViewModel extends ChangeNotifier {
  final String firstName;
  final String lastName;
  final String userId;
  final String userProfileUrl;
  int selectedIndex = 0;

  late List<Widget> pages;

  MainViewModel({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userProfileUrl,
  }) {
    pages = [
      FeedScreen(
        firstName: firstName,
        lastName: lastName,
        userId: userId,
        userProfileUrl: userProfileUrl,
      ),
      Container(), // Placeholder for add post screen
      ProfileScreen(userId: userId),
    ];
  }

  void onItemTapped(int index, BuildContext context) {
    if (index == 1) {
      navigateToCreatePostScreen(context);
    } else {
      selectedIndex = index;
      notifyListeners();
    }
  }

  Future<void> navigateToCreatePostScreen(BuildContext context) async {
    final newPost = await Navigator.push<Post>(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          userName: '$firstName $lastName',
          userProfileUrl: userProfileUrl,
        ),
      ),
    );
    if (newPost != null) {
      selectedIndex = 0; // Go back to feed screen after post is created
      pages[0] = FeedScreen(
        firstName: firstName,
        lastName: lastName,
        userId: userId,
        userProfileUrl: userProfileUrl,
      ); // Refresh the feed screen
      notifyListeners();
    }
  }
}
