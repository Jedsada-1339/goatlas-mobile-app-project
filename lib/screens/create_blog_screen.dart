import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/blog_model.dart';
import '../components/blog_service.dart';

class CreateBlogScreen extends StatefulWidget {
  final String authorName;
  final String authorAvatar;

  const CreateBlogScreen({
    super.key,
    required this.authorName,
    required this.authorAvatar,
  });

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  File? _coverImageFile; // รูปที่เลือกจากเครื่อง
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // เลือกรูปปก
  // ─────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // บีบอัดให้เล็กลงนิดนึง
    );
    if (picked != null) {
      setState(() => _coverImageFile = File(picked.path));
    }
  }

  // ─────────────────────────────────────────────
  // เพิ่ม Tag
  // ─────────────────────────────────────────────
  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed) && _tags.length < 5) {
      setState(() {
        _tags.add(trimmed);
        _tagController.clear();
      });
    }
  }

  // ─────────────────────────────────────────────
  // บันทึกบทความ → Firebase
  // ─────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกรูปปกบทความ')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. อัปโหลดรูปไป Firebase Storage → ได้ URL
      final imageUrl = await BlogService.instance.uploadCoverImage(
        _coverImageFile!,
      );

      // 2. คำนวณเวลาอ่านคร่าวๆ (~200 คำ/นาที)
      final wordCount = _contentController.text.trim().split(' ').length;
      final readTime = (wordCount / 200).ceil().clamp(1, 60);

      // 3. สร้าง BlogPost object
      final newPost = BlogPost(
        id: '', // Firestore จะสร้าง ID ให้
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: widget.authorName,
        authorAvatar: widget.authorAvatar,
        coverImage: imageUrl,
        publishedDate: DateTime.now(),
        readTime: readTime,
        tags: _tags,
      );

      // 4. บันทึกลง Firestore
      await BlogService.instance.createBlog(newPost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เผยแพร่บทความสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // กลับหน้า BlogScreen (StreamBuilder อัปเดตเอง)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'เขียนบทความ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // ปุ่มเผยแพร่
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
                      'เผยแพร่',
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
              const Text(
                'หัวข้อบทความ *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: _inputDecoration('ใส่หัวข้อบทความ...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณาใส่หัวข้อ' : null,
              ),

              const SizedBox(height: 20),

              // ─── เนื้อหา ───
              const Text(
                'เนื้อหา *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: _inputDecoration('เขียนเนื้อหาบทความที่นี่...'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณาใส่เนื้อหา' : null,
              ),

              const SizedBox(height: 20),

              // ─── Tags ───
              const Text(
                'แท็ก (สูงสุด 5 แท็ก)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: _inputDecoration('เช่น เที่ยว, อาหาร...'),
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
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.w600,
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          image: _coverImageFile != null
              ? DecorationImage(
                  image: FileImage(_coverImageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _coverImageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'เลือกรูปปกบทความ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'แตะเพื่อเลือกรูปจากอัลบั้ม',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: _pickImage,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
