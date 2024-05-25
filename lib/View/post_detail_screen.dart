import 'dart:io';
import 'package:flutter/material.dart';
import 'package:social_media/Model/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/View/full_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final String firstName;
  final String lastName;
  final String userId;

  PostDetailScreen({
    required this.post,
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final Map<String, Map<String, String>> _userProfiles = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfiles();
  }

  Future<void> _loadUserProfiles() async {
    for (var comment in widget.post.comments) {
      if (!_userProfiles.containsKey(comment.user)) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(comment.user)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userProfiles[comment.user] = {
              'name': '${userDoc['firstName']} ${userDoc['lastName']}',
              'profileImageUrl': userDoc['profileImageUrl'] ?? '',
            };
          });
        }
      }
    }
  }

  Future<void> _addComment(String text) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Comment newComment = Comment(user: widget.userId, commentText: text);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.arrayUnion([newComment.toJson()])
      });

      setState(() {
        _commentController.clear();
        widget.post.comments.add(newComment);
        _userProfiles[widget.userId] = {
          'name': '${widget.firstName} ${widget.lastName}',
          'profileImageUrl': '',
        };
      });
    } catch (e) {
      print('Yorum eklenirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _likePost() async {
    await likePost(widget.post, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    DateTime postDateTime = DateTime.parse(widget.post.date);
    String formattedDate =
        "${postDateTime.toLocal().year}-${postDateTime.toLocal().month}-${postDateTime.toLocal().day}";
    String formattedTime =
        "${postDateTime.toLocal().hour.toString().padLeft(2, '0')}:${postDateTime.toLocal().minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 65, 152, 223),
        title: Text('Gönderi Detayları'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.header, style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 8.0),
            Text(widget.post.body),
            if (widget.post.imageFiles.isNotEmpty) _buildPostImages(context),
            _buildPostDetails(formattedDate, formattedTime),
            SizedBox(height: 8.0), // Yorumlar ile gönderi arasında boşluk
            Expanded(
              child: ListView.builder(
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  final userProfile = _userProfiles[comment.user] ??
                      {'name': 'User Name', 'profileImageUrl': ''};
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: userProfile['profileImageUrl'] !=
                                  null
                              ? NetworkImage(userProfile['profileImageUrl']!)
                              : AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                          radius: 20,
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(comment.commentText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(BuildContext context) {
    int maxImages = 2;
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: List<Widget>.generate(
        widget.post.imageFiles.length > maxImages
            ? maxImages + 1
            : widget.post.imageFiles.length,
        (index) {
          if (index < maxImages) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageGallery(
                      imageFiles: widget.post.imageFiles
                          .map((path) => File(path))
                          .toList(),
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Image.network(
                widget.post.imageFiles[index],
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
                      imageFiles: widget.post.imageFiles
                          .map((path) => File(path))
                          .toList(),
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
                    '+${widget.post.imageFiles.length - maxImages}',
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

  Widget _buildPostDetails(String formattedDate, String formattedTime) {
    bool isLiked = widget.post.likedBy.contains(widget.userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(formattedDate),
            SizedBox(
              width: 18,
            ),
            Text(formattedTime),
          ],
        ), // Tarih bilgisi
        // Saat bilgisi
        SizedBox(height: 8.0), // Tarih ve saat ile butonlar arasında boşluk
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: isLiked ? Colors.blue : Colors.black,
                  ),
                  onPressed: _likePost,
                ),
                Text('${widget.post.likes}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {},
                ),
                Text('${widget.post.comments.length}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Yorum ekleyin...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            _addComment(_commentController.text);
          },
        ),
      ],
    );
  }
}
