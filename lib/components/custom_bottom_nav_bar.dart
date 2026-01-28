import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/create_trip_screen.dart';
import '../screens/blog_screen.dart';
import '../screens/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  void _onTap(BuildContext context, int index) {
    // ถ้ากดปุ่มเดิมที่อยู่แล้ว ไม่ต้องทำอะไร
    if (index == currentIndex) return;

    // Navigate ไปหน้าที่เลือก
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const CreateTripScreen();
        break;
      case 2:
        screen = const BlogScreen();
        break;
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    // ใช้ pushReplacement เพื่อไม่ให้ stack หน้าจอซ้อนกัน
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero, // ไม่มี animation
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'แผนที่'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'บล็อก'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
