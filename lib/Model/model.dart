import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String user;
  String commentText;

  Comment({required this.user, required this.commentText});

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'commentText': commentText,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'],
      commentText: json['commentText'],
    );
  }
}

class Post {
  String id;
  String date;
  String header;
  String body;
  List<String> imageFiles;
  List<Comment> comments;
  int likes;
  List<String> likedBy;
  String userName;
  String userProfileUrl;

  Post({
    this.id = '',
    required this.date,
    required this.header,
    required this.body,
    required this.imageFiles,
    required this.comments,
    required this.likes,
    required this.likedBy,
    required this.userName,
    required this.userProfileUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'header': header,
      'body': body,
      'imageFiles': imageFiles,
      'comments': comments.map((c) => c.toJson()).toList(),
      'likes': likes,
      'likedBy': likedBy,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      header: json['header'] ?? '',
      body: json['body'] ?? '',
      imageFiles: List<String>.from(json['imageFiles'] ?? []),
      comments: List<Comment>.from(
        (json['comments'] ?? []).map((c) => Comment.fromJson(c)),
      ),
      likes: json['likes'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      userName: json['userName'] ?? '',
      userProfileUrl: json['userProfileUrl'] ?? '',
    );
  }
}

Future<void> addComment(Post post, String commentText, String user) async {
  Comment newComment = Comment(user: user, commentText: commentText);
  post.comments.add(newComment);

  await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
    'comments': post.comments.map((c) => c.toJson()).toList(),
  });
}

Future<void> likePost(Post post, String userId) async {
  if (!post.likedBy.contains(userId)) {
    post.likes += 1;
    post.likedBy.add(userId);

    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likes': post.likes,
      'likedBy': post.likedBy,
    });
  }
}
