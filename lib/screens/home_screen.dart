import 'package:flutter/material.dart';
import 'package:goatlas/components/trip_card.dart';
import 'package:goatlas/screens/blog_information_screen.dart';
import '../models/destination.dart';
import '../models/trip.dart';
import '../models/blog_model.dart';
import '../components/custom_search_bar.dart';
import '../components/category_chip.dart';
import '../components/destination_card.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/blog_card.dart';
import '../components/drawer_listview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ยอดนิยม';
  String _selectedTripCategory = 'ยอดนิยม';

  final List<String> _categories = [
    'ยอดนิยม',
    'ผจญภัย',
    'ชิมความ',
    'วัฒนธรรม',
    'ธรรมชาติ',
  ];

  final List<String> _tripCategories = ['ยอดนิยม', 'ไปสูงสุด', 'ไปบ่อยช่วงนี้'];

  // ข้อมูลตัวอย่าง
  final List<Destination> _destinations = [
    Destination(
      id: '1',
      name: 'เกาะพีพี',
      location: 'จังหวัดกระบี่',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
      category: 'ยอดนิยม',
      isFavorite: true,
      rating: 4.8,
    ),
    Destination(
      id: '2',
      name: 'อุทยานประวัติศาสตร์',
      location: 'พระนครศรีอยุธยา',
      imageUrl: 'https://images.unsplash.com/photo-1528181304800-259b08848526',
      category: 'วัฒนธรรม',
      isFavorite: false,
      rating: 4.6,
    ),
    Destination(
      id: '3',
      name: 'ดอยอินทนนท์',
      location: 'จังหวัดเชียงใหม่',
      imageUrl: 'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
      category: 'ธรรมชาติ',
      isFavorite: false,
      rating: 4.9,
    ),
  ];

  // ข้อมูลทริปตัวอย่าง
  final List<Trip> _tripDestinations = [
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
      isFavorite: false,
      rating: 4.9,
    ),
  ];

  // ข้อมูลบล็อกโพสต์ตัวอย่าง
  final List<BlogPost> _blogPosts = [
    BlogPost(
      id: '1',
      title: '10 สถานที่ท่องเที่ยวสุดฮิตในภาคเหนือ',
      content:
          'เที่ยวภาคเหนือต้องไปไหนบ้าง? เรามีคำตอบมาแนะนำ! จากเชียงใหม่ เชียงราย ไปจนถึงแม่ฮ่องสอน ที่เที่ยวสวยๆ เพียบ อากาศดี บรรยากาศชิลล์ๆ เหมาะกับการพักผ่อนและถ่ายรูปสวยๆ',
      authorName: 'สมชาย ใจดี',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Somchai&background=FF5722&color=fff',
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
      authorName: 'นิดา เที่ยวสนุก',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Nida&background=9C27B0&color=fff',
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
      authorName: 'ปรัชญา รักเมืองไทย',
      authorAvatar:
          'https://ui-avatars.com/api/?name=Prachaya&background=3F51B5&color=fff',
      coverImage:
          'https://images.unsplash.com/photo-1563492065599-3520f775eeed',
      publishedDate: DateTime.now().subtract(const Duration(days: 2)),
      readTime: 10,
      likes: 312,
      comments: 45,
      tags: ['กรุงเทพฯ', 'อาหาร'],
    ),
  ];
  // กรองสถานที่ท่องเที่ยวตามหมวดหมู่ที่เลือก
  List<Destination> get _filteredDestinations {
    if (_selectedCategory == 'ยอดนิยม') {
      return _destinations;
    }
    return _destinations.where((d) => d.category == _selectedCategory).toList();
  }

  // กรองทริปตามหมวดหมู่ที่เลือก
  List<Trip> get _filteredTrips {
    if (_selectedTripCategory == 'ยอดนิยม') {
      return _tripDestinations;
    }

    if (_selectedTripCategory == 'ไปสูงสุด') {
      return [..._tripDestinations]
        ..sort((a, b) => b.rating.compareTo(a.rating));
    }

    if (_selectedTripCategory == 'ไปบ่อยช่วงนี้') {
      return _tripDestinations.where((t) => t.isFavorite).toList();
    }

    return _tripDestinations;
  }

  void _toggleFavorite(int index) {
    setState(() {
      final destination = _destinations[index];
      _destinations[index] = destination.copyWith(
        isFavorite: !destination.isFavorite,
      );
    });
  }

  void _toggleTripFavorite(int index) {
    setState(() {
      final trip = _tripDestinations[index];
      _tripDestinations[index] = trip.copyWith(isFavorite: !trip.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Right Side Drawer Menu
      endDrawer: Drawer(child: DrawerListview()),

      // Main Body
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1559827260-dc66d52bef19',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            'https://media.tenor.com/Yc03a6WmAYsAAAAe/cj-chorando-de-felicidade.png',
                            // 'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'สวัสดีค่ะ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Carl',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 52)),
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomSearchBar(
                      controller: _searchController,
                      onSearchPressed: () {},
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Main Content Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Text(
                            'สถานที่ท่องเที่ยวแนะนำ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Category Chips
                        SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              return CategoryChip(
                                label: _categories[index],
                                isSelected:
                                    _selectedCategory == _categories[index],
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = _categories[index];
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Destination Cards
                        SizedBox(
                          height: 300,
                          child: _filteredDestinations.isEmpty
                              ? Center(
                                  child: Text(
                                    'ไม่พบสถานที่ท่องเที่ยว',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  itemCount: _filteredDestinations.length,
                                  itemBuilder: (context, index) {
                                    final destination =
                                        _filteredDestinations[index];
                                    final realIndex = _destinations.indexOf(
                                      destination,
                                    );
                                    return DestinationCard(
                                      destination: destination,
                                      height: 300,
                                      width: 200,
                                      onFavoriteToggle: () =>
                                          _toggleFavorite(realIndex),
                                      onTap: () {},
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 10),

                        // Trip Section Title
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Text(
                            'ทริปยอดนิยม',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 45,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _tripCategories.length,
                            itemBuilder: (context, index) {
                              return CategoryChip(
                                label: _tripCategories[index],
                                isSelected:
                                    _selectedTripCategory ==
                                    _tripCategories[index],
                                onTap: () {
                                  setState(() {
                                    _selectedTripCategory =
                                        _tripCategories[index];
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Trip Cards
                        SizedBox(
                          height: 250,
                          child: _filteredTrips.isEmpty
                              ? Center(
                                  child: Text(
                                    'ไม่พบสถานที่ท่องเที่ยว',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  itemCount: _filteredTrips.length,
                                  itemBuilder: (context, index) {
                                    final destination = _filteredTrips[index];
                                    final realIndex = _tripDestinations.indexOf(
                                      destination,
                                    );
                                    return TripCard(
                                      trip: _tripDestinations[index],
                                      height: 250,
                                      width: 250,
                                      onFavoriteToggle: () =>
                                          _toggleTripFavorite(realIndex),
                                      onTap: () {},
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 20),

                        // Blog Cards
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _blogPosts.length,
                            itemBuilder: (context, index) {
                              final post = _blogPosts[index];
                              return BlogCard(
                                post: post,
                                onTap: () {
                                  // Navigate to blog detail
                                  // TODO: ไปหน้ารายละเอียดบทความ
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BlogInformationScreen(post: post),
                                    ),
                                  );
                                },
                                showPostImage: false,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
