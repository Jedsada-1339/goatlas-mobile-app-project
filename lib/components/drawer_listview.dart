import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/faq_support_screen.dart';

class DrawerListview extends StatelessWidget {
  const DrawerListview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Profile Header =====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1A73E8), const Color(0xFF0D47A1)],
            ),
          ),
          // Header Content with SafeArea
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    image: const DecorationImage(
                      image: CachedNetworkImageProvider(
                        'https://media.tenor.com/Yc03a6WmAYsAAAAe/cj-chorando-de-felicidade.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                const Text(
                  'Carl Johnson',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                const Text(
                  'carl.johnson@email.com',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  children: const [
                    _StatItem(label: 'ทริป', value: '12'),
                    SizedBox(width: 24),
                    _StatItem(label: 'บุ๊กมาร์ก', value: '8'),
                    SizedBox(width: 24),
                    _StatItem(label: 'คะแนน', value: '67'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ===== Menu Items =====
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),

              // --- หมวด การท่องเที่ยว ---
              _SectionHeader(title: 'การท่องเที่ยว'),

              _DrawerItem(
                icon: Icons.star_rounded,
                label: 'คะแนน & รางวัล',
                trailingText: '67 pts',
                color: const Color(0xFFFFB300),
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.bookmark_rounded,
                label: 'บุ๊กมาร์ก',
                color: const Color(0xFF1A73E8),
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.history_rounded,
                label: 'ทริปที่ผ่านมา',
                color: const Color(0xFF26A69A),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 4),
              const Divider(indent: 20, endIndent: 20, height: 16),

              // --- หมวด การตั้งค่า ---
              _SectionHeader(title: 'การตั้งค่า'),

              _DrawerItem(
                icon: Icons.person_rounded,
                label: 'โปรไฟล์',
                color: const Color(0xFF42A5F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ),
              ),
              _DrawerItem(
                icon: Icons.notifications_rounded,
                label: 'การแจ้งเตือน',
                color: const Color(0xFFEF5350),
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: 'ตั้งค่า',
                color: const Color(0xFF78909C),
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.help_rounded,
                label: 'ความช่วยเหลือ',
                color: const Color(0xFF66BB6A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaqSupportPage()),
                ),
              ),

              const SizedBox(height: 4),
              const Divider(indent: 20, endIndent: 20, height: 16),

              // --- Logout ---
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'ออกจากระบบ',
                color: const Color(0xFFEF5350),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ),
                isLogout: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== Stat Item (ใน Header) =====
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

// ===== Section Header =====
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF90A4AE),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ===== Drawer Menu Item =====
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? trailingText;
  final bool isLogout;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.trailingText,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isLogout ? Colors.red.withOpacity(0.04) : Colors.transparent,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLogout ? Colors.red : const Color(0xFF37474F),
              ),
            ),
            trailing: trailingText != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trailingText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
