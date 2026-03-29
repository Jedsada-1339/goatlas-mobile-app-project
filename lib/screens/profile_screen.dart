import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/trip_card_for_profile.dart';
import '../components/blog_card.dart';
import '../models/trip_model.dart';
import '../models/blog_model.dart';
import '../utills/firebase_service.dart';
import '../components/blog_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firebaseService = FirebaseService();
  String _username = 'กำลังโหลด...';
  String _email = '';
  String? _photoUrl;
  bool _isLoading = true;
  int _point = 0; // ตัวแปรเก็บคะแนนของผู้ใช้

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final userData = await _firebaseService.getUserData(user.uid);
      if (mounted && userData != null) {
        setState(() {
          _username = userData['username'] ?? 'ผู้ใช้งาน';
          _email = userData['email'] ?? user.email ?? '';
          _photoUrl = userData['photoUrl'];
          _point = userData['points'] ?? 0; // ดึงคะแนนจาก Firestore
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _toggleFavorite(TripModel trip) async {
    try {
      await _firebaseService.toggleTripFavorite(trip.id, !trip.isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // เพิ่มฟังก์ชันนี้ใน class _ProfileScreenState

  void _showEditProfileDialog() {
    final TextEditingController _usernameController = TextEditingController(
      text: _username,
    );
    final TextEditingController _passwordController = TextEditingController();
    bool _isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // เพื่อให้คีย์บอร์ดไม่บัง
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'แก้ไขโปรไฟล์',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // แก้ไข Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username ใหม่',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // แก้ไข Password
              // Todo: สร้าง Logic สำหรับการอัปเดต Password ใน Firebase Auth และเชื่อมต่อกับฟังก์ชันนี้
              // TextField(
              //   controller: _passwordController,
              //   obscureText: true,
              //   decoration: const InputDecoration(
              //     labelText: 'รหัสผ่านใหม่ (ปล่อยว่างถ้าไม่ต้องการเปลี่ยน)',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.lock),
              //   ),
              // ),
              // const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          setModalState(() => _isUpdating = true);
                          try {
                            // 1. อัปเดต Username ถ้ามีการเปลี่ยนแปลง
                            if (_usernameController.text.trim() != _username) {
                              await _firebaseService.updateUsername(
                                _usernameController.text.trim(),
                              );
                            }

                            // 2. อัปเดต Password ถ้ามีการกรอกข้อมูล
                            if (_passwordController.text.isNotEmpty) {
                              if (_passwordController.text.length < 6) {
                                throw Exception(
                                  'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร',
                                );
                              }
                              await _firebaseService.updateUserPassword(
                                _passwordController.text,
                              );
                            }

                            if (mounted) {
                              Navigator.pop(context);
                              _loadUserData(); // โหลดข้อมูลหน้าจอใหม่
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('อัปเดตข้อมูลสำเร็จ'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setModalState(() => _isUpdating = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4), // สีพื้นหลังปุ่ม
                    foregroundColor: Colors.white, // สีตัวอักษรบนปุ่ม
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('บันทึกการเปลี่ยนแปลง'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TripModel>>(
      stream: _firebaseService.getTripsStream(),
      builder: (context, tripSnapshot) {
        final myTrips = tripSnapshot.data ?? [];

        return StreamBuilder<List<BlogPost>>(
          stream: BlogService.instance.getBlogsStream(),
          builder: (context, blogSnapshot) {
            // กรองเฉพาะบล็อกของ user ที่ล็อกอินอยู่
            final allBlogs = blogSnapshot.data ?? [];
            final myBlogs = allBlogs
                .where((b) => b.authorName == _username)
                .toList();

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: const Color(0xFFF5F5F5),
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text(
                    'โปรไฟล์',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.black87),
                  automaticallyImplyLeading: false,
                ),
                body: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NestedScrollView(
                        headerSliverBuilder: (context, innerScrolling) {
                          return [
                            SliverToBoxAdapter(child: _profileHeader()),
                            // --- Stats Row ---
                            SliverToBoxAdapter(
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _statColumn(
                                      'ทริป',
                                      myTrips.length.toString(),
                                    ),
                                    const SizedBox(width: 40),
                                    // จำนวนบล็อกจาก Firebase จริงๆ
                                    _statColumn(
                                      'บล็อก',
                                      myBlogs.length.toString(),
                                    ),
                                    const SizedBox(width: 40),
                                    _statColumn('คะแนน', '$_point'),
                                  ],
                                ),
                              ),
                            ),
                            // --- TabBar ---
                            SliverPersistentHeader(
                              delegate: _StickyTabBarDelegate(
                                tabBar: const TabBar(
                                  labelColor: Color(0xFF00BCD4),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Color(0xFF00BCD4),
                                  indicatorWeight: 3,
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  tabs: [
                                    Tab(text: 'ทริปของฉัน'),
                                    Tab(text: 'บล็อกของฉัน'),
                                  ],
                                ),
                              ),
                              pinned: true,
                            ),
                          ];
                        },
                        body: TabBarView(
                          children: [
                            // ===== Tab 1: My Trips =====
                            _TripTabContent(
                              snapshot: tripSnapshot,
                              onFavoriteToggle: _toggleFavorite,
                            ),
                            // ===== Tab 2: My Blogs (ดึงข้อมูลจาก Firebase) =====
                            _BlogTabContent(
                              snapshot: blogSnapshot,
                              myBlogs: myBlogs,
                            ),
                          ],
                        ),
                      ),
                bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: CachedNetworkImageProvider(
              _photoUrl != null && _photoUrl!.isNotEmpty
                  ? _photoUrl!
                  : 'https://ui-avatars.com/api/?name=$_username&background=00BCD4&color=fff&size=200',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(_email, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('แก้ไขโปรไฟล์'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00BCD4),
              side: const BorderSide(color: Color(0xFF00BCD4)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      ],
    );
  }
}

// ===== Trip Tab: ดึงข้อมูลจาก Firebase ผ่าน StreamBuilder =====
class _TripTabContent extends StatelessWidget {
  final AsyncSnapshot<List<TripModel>> snapshot;
  final void Function(TripModel) onFavoriteToggle;

  const _TripTabContent({
    required this.snapshot,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'เกิดข้อผิดพลาด: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final trips = snapshot.data ?? [];

    // Empty state
    if (trips.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีทริป',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TripCardForProfile(
              trip: trips[index],
              height: 200,
              width: double.infinity,
              onTap: () {},
              onFavoriteToggle: () => onFavoriteToggle(trips[index]),
            ),
          ),
        );
      },
    );
  }
}

// ===== Blog Tab: ดึงข้อมูลจาก Firebase ผ่าน StreamBuilder =====
class _BlogTabContent extends StatelessWidget {
  final AsyncSnapshot<List<BlogPost>> snapshot;
  final List<BlogPost> myBlogs; // บล็อกที่กรองเฉพาะของ user แล้ว

  const _BlogTabContent({required this.snapshot, required this.myBlogs});

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'เกิดข้อผิดพลาด: ${snapshot.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Empty state
    if (myBlogs.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีบล็อก',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myBlogs.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BlogCard(
              post: myBlogs[index],
              width: double.infinity,
              margin: EdgeInsets.zero,
              onTap: () {},
            ),
          ),
        );
      },
    );
  }
}

// ===== Sticky TabBar Delegate =====
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate({required this.tabBar});

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
