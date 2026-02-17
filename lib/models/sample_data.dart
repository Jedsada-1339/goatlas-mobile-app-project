import 'place_model.dart';
import 'trip_model.dart';
import 'day_plan_model.dart';

/// ข้อมูลตัวอย่างสำหรับสถานที่ท่องเที่ยวในประเทศไทย
class SampleData {
  /// รายการสถานที่ท่องเที่ยว
  static List<PlaceModel> get places => [
    // ภาคเหนือ
    PlaceModel(
      id: 'p1',
      name: 'วัดพระธาตุดอยสุเทพ',
      description:
          'วัดสำคัญคู่เมืองเชียงใหม่ ตั้งอยู่บนดอยสุเทพ มีพระธาตุสีทองอร่าม',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
      location: 'เชียงใหม่',
      rating: 4.9,
      duration: '2-3 ชม.',
      latitude: 18.8049,
      longitude: 98.9218,
    ),
    PlaceModel(
      id: 'p2',
      name: 'ดอยอินทนนท์',
      description: 'จุดสูงสุดของประเทศไทย อากาศเย็นสบาย ชมทะเลหมอกยามเช้า',
      category: 'ธรรมชาติ',
      imageUrl: 'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
      location: 'เชียงใหม่',
      rating: 4.8,
      duration: 'ครึ่งวัน',
      latitude: 18.5885,
      longitude: 98.4870,
    ),
    PlaceModel(
      id: 'p3',
      name: 'ถนนคนเดินท่าแพ',
      description: 'ตลาดนัดสุดชิค ของกินอร่อย งานศิลปะ และสินค้าแฮนด์เมด',
      category: 'ช้อปปิ้ง',
      imageUrl: 'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f',
      location: 'เชียงใหม่',
      rating: 4.6,
      duration: '2-3 ชม.',
      latitude: 18.7877,
      longitude: 98.9932,
    ),
    PlaceModel(
      id: 'p4',
      name: 'ร้านข้าวซอยแม่สาย',
      description: 'ข้าวซอยเส้นนุ่ม น้ำซุปเข้มข้น รสชาติดั้งเดิมต้นตำรับ',
      category: 'ร้านอาหาร',
      imageUrl: 'https://images.unsplash.com/photo-1569562211093-4ed0d0758f12',
      location: 'เชียงใหม่',
      rating: 4.7,
      duration: '1 ชม.',
      latitude: 18.8023,
      longitude: 98.9733,
    ),
    PlaceModel(
      id: 'p5',
      name: 'วัดร่องขุ่น',
      description:
          'วัดสีขาวบริสุทธิ์ งานศิลปะอันวิจิตรงดงาม สถาปัตยกรรมเอกลักษณ์',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1559735043-3aeddaf34e09',
      location: 'เชียงราย',
      rating: 4.9,
      duration: '1-2 ชม.',
      latitude: 19.8242,
      longitude: 99.7630,
    ),

    // ภาคใต้
    PlaceModel(
      id: 'p6',
      name: 'เกาะพีพี',
      description: 'หมู่เกาะสวรรค์แห่งอันดามัน ทะเลสีเขียวมรกต หาดทรายขาว',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
      location: 'กระบี่',
      rating: 4.8,
      duration: 'ทั้งวัน',
      latitude: 7.7407,
      longitude: 98.7784,
    ),
    PlaceModel(
      id: 'p7',
      name: 'หาดป่าตอง',
      description: 'หาดยอดนิยมของภูเก็ต กิจกรรมทางน้ำครบครัน ไนท์ไลฟ์สุดมัน',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1559527134-0b5d69a2ac1e',
      location: 'ภูเก็ต',
      rating: 4.5,
      duration: 'ครึ่งวัน',
      latitude: 7.8967,
      longitude: 98.2952,
    ),
    PlaceModel(
      id: 'p8',
      name: 'เขาพังกา',
      description: 'วิวพอยท์ชมอ่าวพังงา เกาะเขาตะปู ความงามที่ต้องมาสัมผัส',
      category: 'ธรรมชาติ',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      location: 'พังงา',
      rating: 4.7,
      duration: 'ครึ่งวัน',
      latitude: 8.3248,
      longitude: 98.6015,
    ),
    PlaceModel(
      id: 'p9',
      name: 'ร้านรกเส้น',
      description: 'ร้านอาหารใต้แท้ๆ ข้าวแกงปักษ์ใต้ รสจัดถึงใจ',
      category: 'ร้านอาหาร',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      location: 'ภูเก็ต',
      rating: 4.6,
      duration: '1 ชม.',
      latitude: 7.8804,
      longitude: 98.3923,
    ),

    // ภาคกลาง
    PlaceModel(
      id: 'p10',
      name: 'วัดพระแก้ว',
      description: 'วัดสำคัญที่สุดในประเทศไทย ประดิษฐานพระแก้วมรกต',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1563492065599-3520f775eeed',
      location: 'กรุงเทพฯ',
      rating: 4.9,
      duration: '2-3 ชม.',
      latitude: 13.7517,
      longitude: 100.4926,
    ),
    PlaceModel(
      id: 'p11',
      name: 'ตลาดน้ำอัมพวา',
      description: 'ตลาดน้ำยามเย็น ล่องเรือชมหิ่งห้อย อาหารทะเลสดใหม่',
      category: 'ท่องเที่ยว',
      imageUrl: 'https://images.unsplash.com/photo-1552566626-52cf81c62f01',
      location: 'สมุทรสงคราม',
      rating: 4.7,
      duration: 'ครึ่งวัน',
      latitude: 13.4260,
      longitude: 99.9547,
    ),
    PlaceModel(
      id: 'p12',
      name: 'อุทยานประวัติศาสตร์อยุธยา',
      description: 'มรดกโลกทางวัฒนธรรม ชมโบราณสถานและวัดเก่าแก่',
      category: 'วัฒนธรรม',
      imageUrl: 'https://images.unsplash.com/photo-1528181304800-259b08848526',
      location: 'อยุธยา',
      rating: 4.8,
      duration: 'ครึ่งวัน',
      latitude: 14.3532,
      longitude: 100.5684,
    ),
    PlaceModel(
      id: 'p13',
      name: 'ไอคอนสยาม',
      description: 'ห้างหรูริมน้ำเจ้าพระยา ช้อปปิ้ง กิน เที่ยว ครบจบในที่เดียว',
      category: 'ช้อปปิ้ง',
      imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a',
      location: 'กรุงเทพฯ',
      rating: 4.6,
      duration: '3-4 ชม.',
      latitude: 13.7268,
      longitude: 100.5108,
    ),
    PlaceModel(
      id: 'p14',
      name: 'เยาวราช',
      description: 'ไชน่าทาวน์เมืองไทย อาหารจีนอร่อย บรรยากาศคึกคัก',
      category: 'ร้านอาหาร',
      imageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b',
      location: 'กรุงเทพฯ',
      rating: 4.5,
      duration: '2-3 ชม.',
      latitude: 13.7408,
      longitude: 100.5085,
    ),

    // ภาคอีสาน
    PlaceModel(
      id: 'p15',
      name: 'อุทยานแห่งชาติภูกระดึง',
      description: 'ภูเขาในตำนาน ปีนขึ้นไปชมทุ่งหญ้าและอากาศเย็นสบาย',
      category: 'ธรรมชาติ',
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
      location: 'เลย',
      rating: 4.8,
      duration: 'ทั้งวัน',
      latitude: 16.8837,
      longitude: 101.7877,
    ),
    PlaceModel(
      id: 'p16',
      name: 'ภูทับเบิก',
      description: 'ทะเลหมอกสุดอลังการ ทุ่งกะหล่ำเขียวขจี อากาศหนาวเย็น',
      category: 'ธรรมชาติ',
      imageUrl: 'https://images.unsplash.com/photo-1470770903676-69b98201ea1c',
      location: 'เพชรบูรณ์',
      rating: 4.7,
      duration: 'ครึ่งวัน',
      latitude: 16.9030,
      longitude: 101.0971,
    ),

    // ที่พัก
    PlaceModel(
      id: 'p17',
      name: 'โรงแรมดาราเทวี',
      description: 'โรงแรมหรูระดับ 5 ดาว ดีไซน์ล้านนา สระว่ายน้ำสวยงาม',
      category: 'ที่พัก',
      imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd',
      location: 'เชียงใหม่',
      rating: 4.9,
      duration: 'พักค้างคืน',
      latitude: 18.7788,
      longitude: 99.0347,
    ),
    PlaceModel(
      id: 'p18',
      name: 'รีสอร์ทริมหาด',
      description: 'รีสอร์ทติดทะเล ห้องพักวิวทะเล สระว่ายน้ำอินฟินิตี้',
      category: 'ที่พัก',
      imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
      location: 'ภูเก็ต',
      rating: 4.8,
      duration: 'พักค้างคืน',
      latitude: 7.9515,
      longitude: 98.2858,
    ),

    // คาเฟ่
    PlaceModel(
      id: 'p19',
      name: 'ม่อนแจ่ม คาเฟ่',
      description: 'คาเฟ่บนดอย วิวทะเลหมอก กาแฟหอม ขนมอร่อย',
      category: 'คาเฟ่',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
      location: 'เชียงใหม่',
      rating: 4.6,
      duration: '1-2 ชม.',
      latitude: 18.9351,
      longitude: 98.8223,
    ),
    PlaceModel(
      id: 'p20',
      name: 'บ้านไร่กาแฟ',
      description: 'คาเฟ่สไตล์รีสอร์ท บรรยากาศร่มรื่น เหมาะพักผ่อน',
      category: 'คาเฟ่',
      imageUrl: 'https://images.unsplash.com/photo-1445116572660-236099ec97a0',
      location: 'เขาใหญ่',
      rating: 4.5,
      duration: '1-2 ชม.',
      latitude: 14.5492,
      longitude: 101.3725,
    ),
  ];

  /// ทริปตัวอย่าง
  static List<TripModel> get trips => [
    TripModel(
      id: 't1',
      name: 'เชียงใหม่ 3 วัน 2 คืน',
      coverImageUrl:
          'https://images.unsplash.com/photo-1598970434795-0c54fe7c0648',
      startDate: DateTime(2025, 8, 15),
      endDate: DateTime(2025, 8, 17),
      isFavorite: true,
      dayPlans: [
        DayPlanModel(
          dayNumber: 1,
          hotelName: 'โรงแรมดาราเทวี',
          places: [
            places.firstWhere((p) => p.id == 'p1'), // วัดพระธาตุดอยสุเทพ
            places.firstWhere((p) => p.id == 'p19'), // ม่อนแจ่ม คาเฟ่
            places.firstWhere((p) => p.id == 'p4'), // ร้านข้าวซอยแม่สาย
            places.firstWhere((p) => p.id == 'p3'), // ถนนคนเดินท่าแพ
          ],
        ),
        DayPlanModel(
          dayNumber: 2,
          hotelName: 'โรงแรมดาราเทวี',
          places: [
            places.firstWhere((p) => p.id == 'p17'), // โรงแรม
            places.firstWhere((p) => p.id == 'p2'), // ดอยอินทนนท์
            places.firstWhere((p) => p.id == 'p19'), // ม่อนแจ่ม
          ],
        ),
        DayPlanModel(
          dayNumber: 3,
          places: [places.firstWhere((p) => p.id == 'p3')],
        ),
      ],
    ),
    TripModel(
      id: 't2',
      name: 'ภูเก็ต-พังงา 4 วัน',
      coverImageUrl:
          'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2025, 9, 4),
      dayPlans: [
        DayPlanModel(
          dayNumber: 1,
          hotelName: 'รีสอร์ทริมหาด',
          places: [
            places.firstWhere((p) => p.id == 'p18'), // รีสอร์ท
            places.firstWhere((p) => p.id == 'p7'), // หาดป่าตอง
            places.firstWhere((p) => p.id == 'p9'), // ร้านอาหาร
          ],
        ),
        DayPlanModel(
          dayNumber: 2,
          hotelName: 'รีสอร์ทริมหาด',
          places: [places.firstWhere((p) => p.id == 'p8')],
        ),
        DayPlanModel(
          dayNumber: 3,
          hotelName: 'รีสอร์ทริมหาด',
          places: [places.firstWhere((p) => p.id == 'p6')],
        ),
        DayPlanModel(
          dayNumber: 4,
          places: [places.firstWhere((p) => p.id == 'p9')],
        ),
      ],
    ),
    TripModel(
      id: 't3',
      name: 'กรุงเทพฯ 2 วัน 1 คืน',
      coverImageUrl:
          'https://images.unsplash.com/photo-1563492065599-3520f775eeed',
      startDate: DateTime(2025, 10, 5),
      endDate: DateTime(2025, 10, 6),
      dayPlans: [
        DayPlanModel(
          dayNumber: 1,
          places: [
            places.firstWhere((p) => p.id == 'p10'),
            places.firstWhere((p) => p.id == 'p14'),
          ],
        ),
        DayPlanModel(
          dayNumber: 2,
          places: [places.firstWhere((p) => p.id == 'p13')],
        ),
      ],
    ),
  ];

  /// หมวดหมู่สถานที่
  static List<String> get placeCategories => [
    'ทั้งหมด',
    'ท่องเที่ยว',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'ร้านอาหาร',
    'คาเฟ่',
    'ที่พัก',
    'ช้อปปิ้ง',
  ];
}
