import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/blog_model.dart';

class BlogService {
  // Singleton pattern
  BlogService._();
  static final BlogService instance = BlogService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _blogsRef =>
      _firestore.collection('blogs');

  // ─────────────────────────────────────────────
  // READ: Stream ดึงบทความทั้งหมด (real-time)
  // ─────────────────────────────────────────────
  Stream<List<BlogPost>> getBlogsStream() {
    return _blogsRef
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BlogPost.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────
  // CREATE: เพิ่มบทความใหม่
  // ─────────────────────────────────────────────
  Future<void> createBlog(BlogPost post) async {
    await _blogsRef.add(post.toMap());
  }

  // ─────────────────────────────────────────────
  // UPLOAD: อัปโหลดรูปปก → คืน URL
  // ─────────────────────────────────────────────
  Future<String> uploadCoverImage(File imageFile) async {
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('blog_covers/$fileName');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  // ─────────────────────────────────────────────
  // UPDATE: อัปเดต likes
  // ─────────────────────────────────────────────
  Future<void> likeBlog(String blogId, int currentLikes) async {
    await _blogsRef.doc(blogId).update({'likes': currentLikes + 1});
  }

  // ─────────────────────────────────────────────
  // DELETE: ลบบทความ
  // ─────────────────────────────────────────────
  Future<void> deleteBlog(String blogId) async {
    await _blogsRef.doc(blogId).delete();
  }
}
