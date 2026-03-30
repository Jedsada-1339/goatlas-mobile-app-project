import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goatlas/components/custom_bottom_nav_bar.dart';
import '../models/blog_model.dart';
import 'dart:convert';

class BlogInformationScreen extends StatelessWidget {
  final BlogPost post;

  const BlogInformationScreen({super.key, required this.post});

  Widget _buildImage(BuildContext context, String imageData) {
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
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                Icons.broken_image,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 50,
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 50),
              const SizedBox(height: 8),
              Text(
                'ไม่สามารถโหลดรูปภาพได้',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // AppBar with Back Button
          SliverAppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'รายละเอียดบทความ',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: colorScheme.onSurface),
                onPressed: () {
                  // TODO: แชร์บทความ
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('แชร์บทความ')));
                },
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border, color: colorScheme.onSurface),
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
                        backgroundColor: colorScheme.primary,
                        child: post.authorAvatar.isEmpty
                            ? Text(
                                post.authorName.isNotEmpty
                                    ? post.authorName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  'Tag : ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
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
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
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
                        child: _buildImage(context, post.coverImage),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.timeAgo,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readTime} นาทีในการอ่าน',
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Divider(height: 1, color: colorScheme.outlineVariant),

                const SizedBox(height: 20),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
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
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Likes
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: colorScheme.error,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${post.likes}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ถูกใจ',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        // Divider
                        Container(
                          height: 30,
                          width: 1,
                          color: colorScheme.outlineVariant,
                        ),

                        // Comments
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${post.comments}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ความคิดเห็น',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
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
