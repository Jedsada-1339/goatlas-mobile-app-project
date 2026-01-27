import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../components/custom_search_bar.dart';
import '../components/category_chip.dart';
import '../components/destination_card.dart';
import 'trip_screen.dart';
import 'blog_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ยอดนิยม';

  final List<String> _categories = [
    'ยอดนิยม',
    'ผจญภัย',
    'ชิมความ',
    'วัฒนธรรม',
    'ธรรมชาติ',
  ];

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

  List<Destination> get _filteredDestinations {
    if (_selectedCategory == 'ยอดนิยม') {
      return _destinations;
    }
    return _destinations.where((d) => d.category == _selectedCategory).toList();
  }

  void _toggleFavorite(int index) {
    setState(() {
      final destination = _destinations[index];
      _destinations[index] = destination.copyWith(
        isFavorite: !destination.isFavorite,
      );
    });
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home screen, do nothing
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BlogScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=Jedsada&background=00BCD4&color=fff',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สวัสดีค่ะ',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            'Jedsada',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomSearchBar(
                    controller: _searchController,
                    onSearchPressed: () {
                      // Handle search
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Content Section
                Expanded(
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
                        Expanded(
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
                                      onFavoriteToggle: () =>
                                          _toggleFavorite(realIndex),
                                      onTap: () {
                                        // Navigate to detail screen
                                      },
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
          currentIndex: 0,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'หน้าหลัก'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'ทริป'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'บล็อก'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'โปรไฟล์'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
