import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorAvatar;
  final String coverImage;
  final DateTime publishedDate;
  final int readTime;
  final int likes;
  final int comments;
  final List<String> tags;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorAvatar,
    required this.coverImage,
    required this.publishedDate,
    this.readTime = 5,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
  });

  // แปลงจาก Firestore → BlogPost
  factory BlogPost.fromMap(String id, Map<String, dynamic> map) {
    return BlogPost(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      coverImage: map['coverImage'] ?? '',
      publishedDate: map['publishedDate'] is Timestamp
          ? (map['publishedDate'] as Timestamp).toDate()
          : DateTime.now(),
      readTime: map['readTime'] ?? 5,
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // แปลงจาก BlogPost → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'coverImage': coverImage,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'readTime': readTime,
      'likes': likes,
      'comments': comments,
      'tags': tags,
    };
  }

  // คำนวณเวลาที่ผ่านมา
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ปีที่แล้ว';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months เดือนที่แล้ว';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }

  // สรุปเนื้อหา (แสดงบางส่วน)
  String get contentPreview {
    if (content.length <= 80) return content;
    return '${content.substring(0, 80)}...';
  }
}
