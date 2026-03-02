import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goatlas/components/custom_bottom_nav_bar.dart';
import '../models/blog_model.dart';
import 'dart:convert';

class BlogInformationScreen extends StatelessWidget {
  final BlogPost post;

  const BlogInformationScreen({super.key, required this.post});

  Widget _buildImage(String imageData) {
    // ตรวจสอบว่าเป็น Base64 หรือไม่
    if (imageData.startsWith('data:image')) {
      try {
        // ตัด "data:image/jpeg;base64," ออก
        final base64String = imageData.split(',').last;
        final bytes = base64Decode(base64String);

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[500],
                size: 50,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey[500], size: 50),
              const SizedBox(height: 8),
              Text(
                'ไม่สามารถโหลดรูปภาพได้',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }
    } else {
      // ถ้าเป็น URL ใช้ CachedNetworkImage
      return CachedNetworkImage(
        imageUrl: imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[500], size: 50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar with Back Button
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'รายละเอียดบทความ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black87),
                onPressed: () {
                  // TODO: แชร์บทความ
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('แชร์บทความ')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.black87),
                onPressed: () {
                  // TODO: บันทึกบทความ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกบทความแล้ว')),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Info Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Author Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: post.authorAvatar.isNotEmpty
                            ? CachedNetworkImageProvider(post.authorAvatar)
                            : null,
                        backgroundColor: const Color(0xFF00BCD4),
                        child: post.authorAvatar.isEmpty
                            ? Text(
                                post.authorName.isNotEmpty
                                    ? post.authorName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Author Name & Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'By ${post.authorName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Tag : ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                // Tags
                                if (post.tags.isNotEmpty)
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: post.tags.take(3).map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00BCD4),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cover Image
                if (post.coverImage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: _buildImage(post.coverImage),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Meta Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.timeAgo,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readTime} นาทีในการอ่าน',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Divider(height: 1, color: Colors.grey[300]),

                const SizedBox(height: 20),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Engagement Section (Like, Comment - Read Only)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Likes
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red[400],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${post.likes}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ถูกใจ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey[300],
                        ),

                        // Comments
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              color: Colors.blue[400],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${post.comments}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ความคิดเห็น',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
