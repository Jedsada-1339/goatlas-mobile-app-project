import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/blog_model.dart';
import '../components/blog_service.dart';
import 'dart:convert';

class EditBlogScreen extends StatefulWidget {
  final BlogPost post;

  const EditBlogScreen({super.key, required this.post});

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _tagController = TextEditingController();

  File? _coverImageFile; // รูปใหม่ที่เลือก
  String? _coverImageBase64; // Base64 ของรูปใหม่
  late List<String> _tags;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ใช้ข้อมูลเดิมจากบล็อก
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _tags = List.from(widget.post.tags);
    // ใช้รูปปกเดิม
    _coverImageBase64 = widget.post.coverImage;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // เลือกรูปปกใหม่
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() {
        _coverImageFile = File(picked.path);
        _coverImageBase64 = 'data:image/jpeg;base64,$base64Image';
      });
    }
  }

  // เพิ่ม Tag
  void _addTag(String tag) {
    final parts = tag.split(',');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && !_tags.contains(trimmed) && _tags.length < 5) {
        setState(() {
          _tags.add(trimmed);
        });
      }
    }
    _tagController.clear();
  }

  // บันทึกการแก้ไข
  Future<void> _submit() async {
    final colorScheme = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) return;
    if (_coverImageBase64 == null || _coverImageBase64!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกรูปปกบทความ')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // คำนวณเวลาอ่านใหม่
      final wordCount = _contentController.text.trim().split(' ').length;
      final readTime = (wordCount / 200).ceil().clamp(1, 60);

      // อัปเดต BlogPost
      final updatedPost = BlogPost(
        id: widget.post.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: widget.post.authorName,
        authorAvatar: widget.post.authorAvatar,
        authorId: widget.post.authorId,
        coverImage: _coverImageBase64!,
        publishedDate: widget.post.publishedDate, // คงวันที่เดิม
        readTime: readTime,
        tags: _tags,
        images: [_coverImageBase64!],
        likes: widget.post.likes, // คงยอดไลค์เดิม
        comments: widget.post.comments, // คงยอดคอมเมนต์เดิม
        likedBy: widget.post.likedBy, // คงรายชื่อคนที่ไลค์เดิม
      );

      // อัปเดตใน Firestore
      await BlogService.instance.updateBlog(updatedPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แก้ไขบทความสำเร็จ!'),
            backgroundColor: colorScheme.primary,
          ),
        );
        Navigator.pop(context); // กลับไปหน้าก่อนหน้า
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'แก้ไขบทความ',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // ปุ่มบันทึก
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: Text(
                      'บันทึก',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── เลือกรูปปก ───
              _buildCoverImagePicker(),

              const SizedBox(height: 24),

              // ─── หัวข้อ ───
              Text(
                'หัวข้อบทความ *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: _inputDecoration('ใส่หัวข้อบทความ...', colorScheme),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณาใส่หัวข้อ' : null,
              ),

              const SizedBox(height: 20),

              // ─── เนื้อหา ───
              Text(
                'เนื้อหา *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: _inputDecoration(
                  'เขียนเนื้อหาบทความที่นี่...',
                  colorScheme,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณาใส่เนื้อหา' : null,
              ),

              const SizedBox(height: 20),

              // ─── Tags ───
              Text(
                'แท็ก (สูงสุด 5 แท็ก)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: _inputDecoration(
                        'เช่น เที่ยว, อาหาร...',
                        colorScheme,
                      ),
                      onFieldSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTag(_tagController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('เพิ่ม'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: เลือกรูปปก
  // ─────────────────────────────────────────────
  Widget _buildCoverImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    Widget imageWidget;

    // กรณีเลือกรูปใหม่จากเครื่อง
    if (_coverImageFile != null) {
      imageWidget = Image.file(_coverImageFile!, fit: BoxFit.cover);
    }
    // กรณีใช้รูปเดิมที่เป็น Base64
    else if (_coverImageBase64 != null &&
        _coverImageBase64!.startsWith('data:image')) {
      try {
        final base64String = _coverImageBase64!.split(',').last;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        imageWidget = Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: const Icon(Icons.broken_image, size: 50),
        );
      }
    }
    // กรณีไม่มีรูป
    else {
      imageWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'เลือกรูปปกบทความ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: imageWidget,
            ),
            // ปุ่มแก้ไข (แสดงเมื่อมีรูป)
            if (_coverImageBase64 != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: colorScheme.surface.withOpacity(0.8),
                  radius: 18,
                  child: IconButton(
                    icon: Icon(Icons.edit, size: 16, color: colorScheme.onSurface),
                    onPressed: _pickImage,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
