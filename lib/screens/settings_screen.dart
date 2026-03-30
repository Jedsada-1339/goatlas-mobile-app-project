import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goatlas/screens/faq_support_screen.dart';
import '../utills/firebase_service.dart';
import '../utills/theme_provider.dart';
import '../components/profile_sheets.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _notificationsEnabled = true;

  // โหลด username จาก Firestore
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final uid = _firebaseService.currentUser?.uid;
    if (uid == null) return;
    final username = await _firebaseService.getUsername(uid);
    if (mounted) setState(() => _username = username ?? '');
  }

  // ---- เปิด Bottom Sheet แก้ไขโปรไฟล์ ----
  Future<void> _openEditProfile() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // รองรับ keyboard ดันขึ้น
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditProfileSheet(currentUsername: _username),
    );

    // ถ้าอัปเดตสำเร็จ ให้ reload username
    if (result == true) {
      await _loadUsername();
    }
  }

  // ---- เปิด Bottom Sheet เปลี่ยนรหัสผ่าน ----
  Future<void> _openChangePassword() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // อ่านค่า isDarkMode จาก ThemeProvider จริงๆ
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การตั้งค่า',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // --- Section: Account ---
          _buildSectionHeader('บัญชีผู้ใช้'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'จัดการโปรไฟล์',
            subtitle: _username.isNotEmpty ? _username : 'แก้ไขชื่อผู้ใช้',
            onTap: _openEditProfile,
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            subtitle: 'เปลี่ยนรหัสผ่าน Firebase Auth',
            onTap: _openChangePassword,
          ),

          const Divider(),

          // --- Section: Preferences ---
          _buildSectionHeader('การตั้งค่าแอป'),

          // Dark mode switch — เชื่อมกับ ThemeProvider จริงๆ
          _buildSettingSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'โหมดมืด (Dark Mode)',
            value: themeProvider.isDarkMode,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),

          _buildSettingSwitch(
            icon: Icons.notifications_active_outlined,
            title: 'การแจ้งเตือน',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          _buildSettingItem(
            icon: Icons.language_rounded,
            title: 'ภาษา',
            subtitle: 'ไทย (Thai)',
            onTap: () {},
          ),

          const Divider(),

          // --- Section: Support & Info ---
          _buildSectionHeader('การช่วยเหลือและข้อมูล'),
          _buildSettingItem(
            icon: Icons.help_outline_rounded,
            title: 'ศูนย์ช่วยเหลือ (FAQ)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FaqSupportPage()),
            ),
          ),

          const SizedBox(height: 30),

          // --- Logout Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () async {
                await _firebaseService.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'ออกจากระบบ',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.cyan.shade700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.cyan, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 13))
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.cyan, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      value: value,
      activeColor: Colors.cyan,
      onChanged: onChanged,
    );
  }
}
