import 'package:flutter/material.dart';
import '../utills/firebase_service.dart'; // ตรวจสอบ path ให้ถูกต้อง

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _currentPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final pts = await _firebaseService.getUserPoints();
    if (mounted) {
      setState(() {
        _currentPoints = pts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คะแนน & รางวัล'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ส่วนแสดงคะแนนปัจจุบัน
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'คะแนนสะสมของคุณ',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentPoints',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Points',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ของรางวัลสำหรับคุณ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // รายการของรางวัล (Mock data)
                Expanded(
                  child: ListView(
                    children: [
                      _rewardItem('ส่วนลดโรงแรม 100 บาท', 500, Icons.hotel),
                      _rewardItem(
                        'บัตรกำนัล Starbucks 50 บาท',
                        300,
                        Icons.local_cafe,
                      ),
                      _rewardItem(
                        'กระเป๋าเดินทาง Exclusive',
                        2000,
                        Icons.card_travel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _rewardItem(String title, int cost, IconData icon) {
    bool canRedeem = _currentPoints >= cost;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          child: Icon(icon, color: Colors.amber.shade800),
        ),
        title: Text(title),
        subtitle: Text('ใช้ $cost คะแนน'),
        trailing: ElevatedButton(
          onPressed: canRedeem ? () => _redeem(title, cost) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canRedeem ? const Color(0xFF1A73E8) : Colors.grey,
          ),
          child: const Text('แลกสิทธิ์', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _redeem(String name, int cost) async {
    // โค้ดสำหรับแลกคะแนน
    await _firebaseService.updatePoints(-cost);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('แลก $name สำเร็จ!')));
    _loadPoints(); // รีโหลดคะแนนใหม่
  }
}
