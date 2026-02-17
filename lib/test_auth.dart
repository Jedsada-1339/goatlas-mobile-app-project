import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utills/auth_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await AuthTest.testRegister();
  await AuthTest.testLogin();
  AuthTest.testCurrentUser();
}
