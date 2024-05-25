import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/View%20Model/FeedViewModel.dart';
import 'package:social_media/View/post_detail_screen.dart';
import 'package:social_media/Model/model.dart';
import 'package:social_media/View/full_screen.dart';

class FeedScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userId;
  final String userProfileUrl;

  FeedScreen({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userProfileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedViewModel(
        firstName: firstName,
        lastName: lastName,
        userId: userId,
        userProfileUrl: userProfileUrl,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 65, 152, 223),
          title: Image.asset(
            "assets/social_app.png",
            height: 65,
          ),
        ),
        body: Consumer<FeedViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: viewModel.posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: viewModel.posts[index],
                  firstName: firstName,
                  lastName: lastName,
                  userId: userId,
                  userProfileImageUrl: userProfileUrl,
                  likePost: viewModel.likePost,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final String firstName;
  final String lastName;
  final String userId;
  final String userProfileImageUrl;
  final Future<void> Function(Post post) likePost;

  PostCard({
    required this.post,
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userProfileImageUrl,
    required this.likePost,
  });

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatDate(post.date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: userProfileImageUrl.isNotEmpty
                      ? NetworkImage(userProfileImageUrl)
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                SizedBox(width: 10.0),
                Text(
                  '${post.userName}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10.0),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Text(
              post.header,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(post.body),
            if (post.imageFiles.isNotEmpty) _buildPostImages(context, post),
            _buildInteractionButtons(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(BuildContext context, Post post) {
    int maxImages = 2;
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: List<Widget>.generate(
        post.imageFiles.length > maxImages
            ? maxImages + 1
            : post.imageFiles.length,
        (index) {
          if (index < maxImages) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageGallery(
                      imageFiles:
                          post.imageFiles.map((path) => File(path)).toList(),
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Image.network(
                post.imageFiles[index],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageGallery(
                      imageFiles:
                          post.imageFiles.map((path) => File(path)).toList(),
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    '+${post.imageFiles.length - maxImages}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInteractionButtons(BuildContext context, Post post) {
    bool isLiked = post.likedBy.contains(userId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                color: isLiked ? Colors.blue : Colors.black,
              ),
              onPressed: () => likePost(post),
            ),
            Text('${post.likes}'),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      post: post,
                      firstName: firstName,
                      lastName: lastName,
                      userId: userId,
                    ),
                  ),
                );
              },
            ),
            Text('${post.comments.length}'),
          ],
        ),
      ],
    );
  }
}
