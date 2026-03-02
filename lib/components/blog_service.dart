import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blog_model.dart';

class BlogService {
  static final instance = BlogService._();
  BlogService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ดึง userId ปัจจุบัน
  String? get _currentUserId => _auth.currentUser?.uid;

  // Reference ไปที่ blogs ของ user ปัจจุบัน
  CollectionReference? get _userBlogsCollection {
    if (_currentUserId == null) return null;
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('blogs');
  }

  // ─────────────────────────────────────────────
  // สร้างบทความใหม่
  // ─────────────────────────────────────────────
  Future<void> createBlog(BlogPost post) async {
    final collection = _userBlogsCollection;
    if (collection == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

    final docRef = collection.doc(); // สร้าง ID ใหม่
    final newPost = BlogPost(
      id: docRef.id,
      title: post.title,
      content: post.content,
      authorName: post.authorName,
      authorAvatar: post.authorAvatar,
      coverImage: post.coverImage,
      publishedDate: post.publishedDate,
      readTime: post.readTime,
      tags: post.tags,
      images: post.images,
    );

    await docRef.set(newPost.toJson());
  }

  // ดึงบทความทั้งหมดของ user (real-time)
  Stream<List<BlogPost>> getBlogsStream() {
    final collection = _userBlogsCollection;
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('publishedDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // ดึงข้อมูลโปรไฟล์ user
          String userName = '';
          String userAvatar = '';
          final uid = _currentUserId;
          if (uid != null) {
            final userDoc = await _firestore.collection('users').doc(uid).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              userName = userData?['username'] ?? '';
              userAvatar = userData?['photoUrl'] ?? '';
            }
          }
          // fallback จาก FirebaseAuth
          final authUser = _auth.currentUser;
          if (userName.isEmpty) {
            userName = authUser?.displayName ?? 'ผู้ใช้';
          }
          if (userAvatar.isEmpty) {
            userAvatar = authUser?.photoURL ?? '';
          }

          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final post = BlogPost.fromJson(data);
            // ใส่ชื่อ/รูปผู้เขียนถ้าข้อมูลว่าง
            return BlogPost(
              id: post.id,
              title: post.title,
              content: post.content,
              authorName: post.authorName.isNotEmpty
                  ? post.authorName
                  : userName,
              authorAvatar: post.authorAvatar.isNotEmpty
                  ? post.authorAvatar
                  : userAvatar,
              coverImage: post.coverImage,
              publishedDate: post.publishedDate,
              readTime: post.readTime,
              likes: post.likes,
              comments: post.comments,
              tags: post.tags,
              images: post.images,
            );
          }).toList();
        });
  }

  // อัปเดตบทความ
  Future<void> updateBlog(BlogPost post) async {
    final collection = _userBlogsCollection;
    if (collection == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

    await collection.doc(post.id).update(post.toJson());
  }

  // ลบบทความ
  Future<void> deleteBlog(String blogId) async {
    final collection = _userBlogsCollection;
    if (collection == null) throw Exception('ไม่พบข้อมูลผู้ใช้');

    await collection.doc(blogId).delete();
  }
}
