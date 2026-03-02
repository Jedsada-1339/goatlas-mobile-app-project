import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/trip_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('--- เริ่มกระบวนการ Google Sign-In ---');

      // โหลด Client ID จาก .env
      final String? serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
      final String? iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? iosClientId
            : null,
        serverClientId: serverClientId,
      );

      // เคลียร์ session เก่าที่อาจจะค้างอยู่
      await googleSignIn.signOut();

      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        print('Google Sign-In: ผู้ใช้ยกเลิกการเข้าระบบ');
        return null;
      }

      print(
        'Google Sign-In: ได้รับข้อมูลเบื้องต้นจาก Google - ${googleUser.email}',
      );

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print(
        'Google Sign-In: Firebase Auth รับรองสิทธิ์สำเร็จ UID-${userCredential.user?.uid}',
      );

      // Save user data to Firestore if it represents a newly created user (or simply merge)
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName ?? 'ผู้ใช้ Google',
          'email': userCredential.user!.email ?? '',
          'photoUrl': userCredential.user!.photoURL ?? '',
          'lastSignIn': FieldValue.serverTimestamp(),
          // Don't overwrite createdAt if it already exists
        }, SetOptions(merge: true));

        // Ensure createdAt is only set once
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (!doc.data()!.containsKey('createdAt')) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'createdAt': FieldValue.serverTimestamp()});
        }
      }

      return userCredential;
    } catch (e) {
      print('Error during Google Sign In: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get username from Firestore
  Future<String?> getUsername(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('username') as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==================== Trip CRUD ====================

  /// Collection reference สำหรับ trips ของ user ปัจจุบัน
  CollectionReference<Map<String, dynamic>> get _tripsCollection {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(uid).collection('trips');
  }

  /// บันทึกทริป (สร้างใหม่หรืออัพเดต)
  Future<void> saveTrip(TripModel trip) async {
    await _tripsCollection.doc(trip.id).set(trip.toMap());
  }

  /// ดึงรายการทริปทั้งหมดแบบ Stream (realtime)
  Stream<List<TripModel>> getTripsStream() {
    return _tripsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TripModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// ดึงรายการทริปทั้งหมดแบบ Future (ใช้ครั้งเดียว)
  Future<List<TripModel>> getTrips() async {
    final snapshot = await _tripsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      return TripModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  /// ลบทริป
  Future<void> deleteTrip(String tripId) async {
    await _tripsCollection.doc(tripId).delete();
  }

  /// อัพเดต favorite
  Future<void> toggleTripFavorite(String tripId, bool isFavorite) async {
    await _tripsCollection.doc(tripId).update({'isFavorite': isFavorite});
  }
}
