import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthTest {
  // ใส่ email/password ที่ต้องการทดสอบตรงนี้
  static const String testEmail = 'Chdove10@gmail.com';
  static const String testPassword = '043491064Sf';
  static const String testUsername = 'TestUser';

  // ทดสอบ Register
  static Future<void> testRegister() async {
    print('========== TEST REGISTER ==========');
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

      print('✅ Register สำเร็จ');
      print('uid: ${credential.user?.uid}');
      print('email: ${credential.user?.email}');

      // บันทึกลง Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'username': testUsername,
            'email': testEmail,
            'createdAt': FieldValue.serverTimestamp(),
          });

      print('✅ บันทึก Firestore สำเร็จ');
    } on FirebaseAuthException catch (e) {
      print('❌ Register ล้มเหลว: ${e.code} - ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
    }
    print('===================================');
  }

  // ทดสอบ Login
  static Future<void> testLogin() async {
    print('========== TEST LOGIN ==========');
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      print('✅ Login สำเร็จ');
      print('uid: ${credential.user?.uid}');
      print('email: ${credential.user?.email}');

      // ดึงข้อมูลจาก Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      print('doc exists: ${doc.exists}');
      print('username: ${doc.data()?['username']}');
      print('email from firestore: ${doc.data()?['email']}');
    } on FirebaseAuthException catch (e) {
      print('❌ Login ล้มเหลว: ${e.code} - ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
    }
    print('================================');
  }

  // ทดสอบ Get Current User
  static void testCurrentUser() {
    print('========== CURRENT USER ==========');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('✅ มี user อยู่');
      print('uid: ${user.uid}');
      print('email: ${user.email}');
    } else {
      print('❌ ไม่มี user (ยังไม่ได้ login)');
    }
    print('==================================');
  }
}
