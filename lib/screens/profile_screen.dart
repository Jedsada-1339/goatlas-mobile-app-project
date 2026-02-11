import 'package:flutter/material.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/trip_card.dart';
import '../components/blog_card.dart';
import '../models/trip.dart';
import '../models/blog_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // --- Mock: ทริปที่เคยสร้าง ---
  static final List<Trip> _myTrips = [
    Trip(
      id: '1',
      name: 'ขึ้นเขาสนุกจังโว้ย',
      location: 'จังหวัดกระบี่',
      imageUrl: 'https://f.ptcdn.info/660/065/000/pws6t51b9x7xqqUGVTC9-o.jpg',
      category: 'ยอดนิยม',
      isFavorite: true,
      rating: 4.8,
    ),
    Trip(
      id: '2',
      name: 'ประวัติศาสตร์น่ารู้จัก',
      location: 'พระนครศรีอยุธยา',
      imageUrl:
          'https://www.chula.ac.th/wp-content/uploads/2018/03/cu_inside_12032018.jpg',
      category: 'วัฒนธรรม',
      isFavorite: false,
      rating: 4.6,
    ),
    Trip(
      id: '3',
      name: 'สวนสนุกหยุดไม่ได้',
      location: 'จังหวัดเชียงใหม่',
      imageUrl:
          'https://mushroomtravelpage.b-cdn.net/wp-content/uploads/2021/11/1167203_1081989495160530_984361401416214698_o-1024x683.jpg',
      category: 'ธรรมชาติ',
      isFavorite: true,
      rating: 4.9,
    ),
    Trip(
      id: '4',
      name: 'ดำน้ำเกาะสมุย',
      location: 'จังหวัดสุราษฎร์ธานี',
      imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
      category: 'ยอดนิยม',
      isFavorite: false,
      rating: 4.7,
    ),
  ];

  // --- Mock: บล็อกที่เคยโพส ---
  static final List<BlogPost> _myBlogs = [
    BlogPost(
      id: '1',
      title: '10 สถานที่ท่องเที่ยวสุดฮิตในภาคเหนือ',
      content:
          'เที่ยวภาคเหนือต้องไปไหนบ้าง? เรามีคำตอบมาแนะนำ! จากเชียงใหม่ เชียงราย ไปจนถึงแม่ฮ่องสอน ที่เที่ยวสวยๆ เพียบ อากาศดี บรรยากาศชิลล์ๆ เหมาะกับการพักผ่อนและถ่ายรูปสวยๆ',
      authorName: 'Jedsada',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff',
      coverImage:
          'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
      publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
      readTime: 8,
      likes: 245,
      comments: 32,
      tags: ['เที่ยวเหนือ', 'ธรรมชาติ'],
    ),
    BlogPost(
      id: '2',
      title: 'เที่ยวทะเลภาคใต้แบบประหยัด Budget 5,000 บาท',
      content:
          'อยากเที่ยวทะเลแต่งบจำกัด? ไม่ต้องกังวล! เรามีเคล็ดลับการเที่ยวทะเลภาคใต้แบบประหยัดมาแชร์ ทั้งที่พัก อาหาร และกิจกรรมสุดคุ้ม งบไม่เกิน 5,000 บาท',
      authorName: 'Jedsada',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff',
      coverImage: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
      publishedDate: DateTime.now().subtract(const Duration(days: 1)),
      readTime: 6,
      likes: 189,
      comments: 28,
      tags: ['ทะเล', 'ประหยัด'],
    ),
    BlogPost(
      id: '3',
      title: 'ตะลุยกรุงเทพฯ 24 ชั่วโมง กินเที่ยวไม่มีเบื่อ',
      content:
          'มีเวลาในกรุงเทพฯ แค่ 24 ชั่วโมง? เราพาไปกินเที่ยวครบทุกมุม ตั้งแต่วัดสวยๆ ตลาดดัง ร้านอาหารเด็ด จนถึงคาเฟ่สุดชิค ครบทุกสไตล์!',
      authorName: 'Jedsada',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff',
      coverImage:
          'https://images.unsplash.com/photo-1563492065599-3520f775eeed',
      publishedDate: DateTime.now().subtract(const Duration(days: 2)),
      readTime: 10,
      likes: 312,
      comments: 45,
      tags: ['กรุงเทพฯ', 'อาหาร'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolling) {
            return [
              SliverToBoxAdapter(child: _ProfileHeader()),
              // --- Stats Row ---
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statColumn('ทริป', _myTrips.length.toString()),
                      const SizedBox(width: 40),
                      _statColumn('บล็อก', _myBlogs.length.toString()),
                      const SizedBox(width: 40),
                      _statColumn('คะแนน', '67'),
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
              _TripTabContent(trips: _myTrips),
              // ===== Tab 2: My Blogs =====
              _BlogTabContent(blogs: _myBlogs),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      ),
    );
  }

  // --- Profile info (avatar, name, email, edit button) ---
  Widget _profileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: const NetworkImage(
              'https://media.tenor.com/Yc03a6WmAYsAAAAe/cj-chorando-de-felicidade.png',
              // 'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff&size=200',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Carl Johnson',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'jedsada@example.com',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
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

  Widget _ProfileHeader() => _profileHeader();

  // --- stat column helper ---
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

// ===== Trip Tab: GridView ของ TripCard =====
class _TripTabContent extends StatelessWidget {
  final List<Trip> trips;

  const _TripTabContent({required this.trips});

  @override
  Widget build(BuildContext context) {
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
            child: TripCard(
              trip: trips[index],
              height: 200,
              width: double.infinity,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        );
      },
    );
  }
}

// ===== Blog Tab: ListView ของ BlogCard =====
class _BlogTabContent extends StatelessWidget {
  final List<BlogPost> blogs;

  const _BlogTabContent({required this.blogs});

  @override
  Widget build(BuildContext context) {
    if (blogs.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีบล็อก',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BlogCard(
              post: blogs[index],
              width: double.infinity,
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
