import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goatlas/components/blog_service.dart';
import 'package:goatlas/components/custom_bottom_nav_bar.dart';
import '../models/blog_model.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goatlas/screens/edit_blog_screen.dart';

class BlogInformationScreen extends StatefulWidget {
  final BlogPost post;

  const BlogInformationScreen({super.key, required this.post});

  @override
  State<BlogInformationScreen> createState() => _BlogInformationScreenState();
}

class _BlogInformationScreenState extends State<BlogInformationScreen> {
  bool _isLiking = false;
  bool get _isOwner {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == widget.post.authorId;
  }

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
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 50,
              ),
              const SizedBox(height: 8),
              Text(
                'ไม่สามารถโหลดรูปภาพได้',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
          child: Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 50,
          ),
        ),
      );
    }
  }

  // ฟังก์ชันกดไลค์
  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    try {
      await BlogService.instance.toggleLike(widget.post.id);
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  // ฟังก์ชันแก้ไขบล็อก
  void _editBlog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlogScreen(post: widget.post),
      ),
    );
  }

  // ฟังก์ชันลบบล็อก
  Future<void> _deleteBlog() async {
    // 1. ถามยืนยัน
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
          'คุณต้องการลบบทความนี้ใช่หรือไม่? การกระทำนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // เก็บ Navigator และ Messenger ไว้ก่อนเผื่อ context เปลี่ยน
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await BlogService.instance.deleteBlog(widget.post.id);

        if (!mounted) return;

        // แสดง SnackBar
        messenger.showSnackBar(
          const SnackBar(
            content: Text('ลบบทความสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // 2. ปิดหน้า Detail (กลับไปหน้า Feed)
        navigator.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // แสดง Bottom Sheet สำหรับเลือกแก้ไขหรือลบ
  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('แก้ไขบทความ'),
              onTap: () {
                Navigator.pop(context);
                _editBlog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'ลบบทความ',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteBlog();
              },
            ),
          ],
        ),
      ),
    );
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('แชร์บทความ')));
                },
              ),
              IconButton(
                icon: Icon(Icons.bookmark_outline, color: colorScheme.onSurface),
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('บันทึกบทความ')));
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blogs')
                  .doc(widget.post.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                // เพิ่มการเช็ค exists เพื่อกัน Crash ตอนลบ
                if (!snapshot.data!.exists) return const SizedBox();

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final post = BlogPost.fromJson({
                  ...data,
                  'id': snapshot.data!.id,
                });

                final uid = FirebaseAuth.instance.currentUser?.uid;
                final isLiked = post.likedBy.contains(uid);

                return Column(
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
                            backgroundImage: widget.post.authorAvatar.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    widget.post.authorAvatar,
                                  )
                                : null,
                            backgroundColor: colorScheme.primary,
                            child: widget.post.authorAvatar.isEmpty
                                ? Text(
                                    widget.post.authorName.isNotEmpty
                                        ? widget.post.authorName[0]
                                              .toUpperCase()
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
                                  'By ${widget.post.authorName}',
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
                                    if (widget.post.tags.isNotEmpty)
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: widget.post.tags.take(3).map(
                                            (tag) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                            },
                                          ).toList(),
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
                            child: _buildImage(
                              post.coverImage,
                            ), // ใช้ post แทน widget.post
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
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.readTime} นาทีในการอ่าน',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                      child: MarkdownBody(
                        data: post.content,

                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                            height: 1.6,
                          ),
                          h1: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          h2: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          strong: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          blockquote: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ─────────────────────────────────────────────
                    // Engagement Section (Like, Comment)
                    // ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // ── Likes (กดได้) ──
                            InkWell(
                              onTap: _isLiking ? null : _handleLike,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    _isLiking
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? colorScheme.error
                                                : colorScheme.onSurfaceVariant,
                                            size: 24,
                                          ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${post.likes}',
                                      style: TextStyle(
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
                              ),
                            ),

                            // Divider
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey[300],
                            ),

                            // ── Comments (ยังไม่ทำงาน) ──
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.post.comments}',
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isOwner
          ? FloatingActionButton(
              onPressed: _showOptionsBottomSheet,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.more_vert, color: Colors.white),
            )
          : null,

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
