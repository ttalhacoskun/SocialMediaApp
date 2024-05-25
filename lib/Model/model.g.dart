// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'model.dart';

// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************

// import 'package:social_media/model.dart';

// Post _$PostFromJson(Map<String, dynamic> json) => Post(
//       date: json['date'] as String,
//       header: json['header'] as String,
//       body: json['body'] as String,
//       imageFiles: (json['imageFiles'] as List<dynamic>)
//           .map((e) => e as String)
//           .toList(),
//       comments: (json['comments'] as List<dynamic>?)
//               ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       likes: (json['likes'] as num?)?.toInt() ?? 0,
//     );

// Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
//       'date': instance.date,
//       'header': instance.header,
//       'body': instance.body,
//       'imageFiles': instance.imageFiles,
//       'comments': instance.comments.map((e) => e.toJson()).toList(),
//       'likes': instance.likes,
//     };

// Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
//       user: json['user'] as String,
//       commentText: json['commentText'] as String,
//     );

// Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
//       'user': instance.user,
//       'commentText': instance.commentText,
//     };
