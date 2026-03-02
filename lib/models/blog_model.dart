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
  final List<String> images;

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
    this.images = const [],
  });

  // แปลงจาก Firestore → BlogPost
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      coverImage: json['coverImage'] ?? '',
      publishedDate: json['publishedDate'] is Timestamp
          ? (json['publishedDate'] as Timestamp).toDate()
          : DateTime.now(),
      readTime: json['readTime'] ?? 5,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  // แปลงจาก BlogPost → Firestore
  Map<String, dynamic> toJson() {
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
      'images': images,
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
