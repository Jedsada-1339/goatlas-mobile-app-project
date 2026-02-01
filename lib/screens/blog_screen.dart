import 'package:flutter/material.dart';
import 'package:goatlas/screens/blog_information_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/blog_card.dart';
import '../models/blog_model.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  // ข้อมูลตัวอย่างบทความบล็อก
  List<BlogPost> _getSampleBlogPosts() {
    return [
      BlogPost(
        id: '1',
        title: 'เที่ยวญี่ปุ่นครั้งแรก ต้องรู้อะไรบ้าง?',
        content:
            'การเดินทางไปญี่ปุ่นครั้งแรกอาจดูน่าตื่นเต้นและกังวลไปพร้อมๆ กัน แต่ถ้าคุณเตรียมตัวให้พร้อม การเดินทางของคุณจะราบรื่นและสนุกสุดๆ ในบทความนี้เราจะมาแชร์เคล็ดลับและสิ่งที่ควรรู้ก่อนไปญี่ปุ่น ตั้งแต่การใช้ขนส่งสาธารณะ การสื่อสาร ไปจนถึงมารยาทพื้นฐานที่ควรรู้',
        authorName: 'สมชาย ใจดี',
        authorAvatar: '', // จะใช้ตัวอักษรแทน
        // coverImage - สามารถแก้ไข URL ภาพได้ภายหลัง
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
        readTime: 8,
        likes: 245,
        comments: 32,
        tags: ['เที่ยวญี่ปุ่น', 'ครั้งแรก'],
      ),
      BlogPost(
        id: '2',
        title: '10 ที่เที่ยวต้องห้ามพลาดในโตเกียว',
        content:
            'โตเกียวเป็นเมืองที่มีทั้งความทันสมัยและวัฒนธรรมดั้งเดิมผสมผสานกันอย่างลงตัว ในบทความนี้เราจะพาไปรู้จัก 10 สถานที่ท่องเที่ยวยอดนิยมที่ไม่ควรพลาด ทั้งวัดเก่าแก่ ย่านช้อปปิ้ง และจุดชมวิวสุดอลังการ พร้อมเคล็ดลับการเดินทางและเวลาที่เหมาะสมในการไป',
        authorName: 'ปรียา สุขสันต์',
        authorAvatar: '',
        // coverImage - สามารถแก้ไข URL ภาพได้ภายหลัง
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        readTime: 12,
        likes: 189,
        comments: 25,
        tags: ['โตเกียว', 'ที่เที่ยว'],
      ),
      BlogPost(
        id: '3',
        title: 'คู่มือกินอาหารญี่ปุ่นฉบับมือใหม่',
        content:
            'อาหารญี่ปุ่นมีความหลากหลายมากกว่าแค่ซูชิและราเมง มาเรียนรู้เกี่ยวกับอาหารญี่ปุ่นแบบต่างๆ วิธีการสั่ง และมารยาทการทานอาหารที่ควรรู้ รวมถึงร้านอาหารแนะนำที่เหมาะกับนักท่องเที่ยว',
        authorName: 'วิชัย รักเที่ยว',
        authorAvatar: '',
        // coverImage - สามารถแก้ไข URL ภาพได้ภายหลัง
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        readTime: 10,
        likes: 312,
        comments: 48,
        tags: ['อาหาร', 'คู่มือ'],
      ),
      BlogPost(
        id: '4',
        title: 'เที่ยวเกียวโตในฤดูใบไม้ร่วง',
        content:
            'เกียวโตในช่วงฤดูใบไม้ร่วงนั้นสวยงามเป็นพิเศษ วัดและสวนต่างๆ เปลี่ยนเป็นสีทองและแดงสวยงาม มาดูกันว่าควรไปชมที่ไหนบ้าง และควรไปช่วงเวลาไหนเพื่อไม่พลาดความงาม',
        authorName: 'นิดา ชื่นชม',
        authorAvatar: '',
        // coverImage - สามารถแก้ไข URL ภาพได้ภายหลัง
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 7)),
        readTime: 7,
        likes: 421,
        comments: 56,
        tags: ['เกียวโต', 'ฤดูใบไม้ร่วง'],
      ),
      BlogPost(
        id: '5',
        title: 'เรียนรู้ภาษาญี่ปุ่นเบื้องต้นก่อนเที่ยว',
        content:
            'การรู้ภาษาญี่ปุ่นเบื้องต้นจะช่วยให้การเดินทางของคุณสะดวกและสนุกมากขึ้น มาเรียนรู้คำศัพท์และประโยคง่ายๆ ที่ใช้บ่อยในการท่องเที่ยว พร้อมเคล็ดลับการออกเสียงให้ถูกต้อง',
        authorName: 'สมศรี เรียนรู้',
        authorAvatar: '',
        // coverImage - สามารถแก้ไข URL ภาพได้ภายหลัง
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 10)),
        readTime: 15,
        likes: 567,
        comments: 89,
        tags: ['ภาษา', 'เรียนรู้'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final blogPosts = _getSampleBlogPosts();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'บล็อก',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: เพิ่มฟังก์ชันค้นหา
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: เพิ่มฟังก์ชันกรอง
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'บทความแนะนำ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เรื่องราวและประสบการณ์การเดินทางจากนักเดินทาง',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Horizontal Featured Posts
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'บทความยอดนิยม',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: ดูทั้งหมด
                        },
                        child: const Text('ดูทั้งหมด'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: blogPosts.length,
                      itemBuilder: (context, index) {
                        return BlogCard(
                          post: blogPosts[index],
                          onTap: () {
                            // TODO: ไปหน้ารายละเอียดบทความ
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlogInformationScreen(
                                  post: blogPosts[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Posts Grid/List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'บทความล่าสุด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: blogPosts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BlogCard(
                          post: blogPosts[index],
                          width: double.infinity,
                          onTap: () {
                            // TODO: ไปหน้ารายละเอียดบทความ
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'เปิดบทความ: ${blogPosts[index].title}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
