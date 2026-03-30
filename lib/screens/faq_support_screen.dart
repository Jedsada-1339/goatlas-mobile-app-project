import 'package:flutter/material.dart';

class FaqSupportPage extends StatefulWidget {
  const FaqSupportPage({super.key});

  @override
  State<FaqSupportPage> createState() => _FaqSupportPageState();
}

class _FaqSupportPageState extends State<FaqSupportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int? _expandedFaqIndex;

  final List<FaqCategory> _faqCategories = [
    FaqCategory(
      title: 'การจองทริป',
      icon: Icons.calendar_today_outlined,
      color: Colors.blue,
      faqs: [
        FaqItem(
          question: 'จองทริปล่วงหน้ากี่วันได้บ้าง?',
          answer:
              'คุณสามารถจองทริปล่วงหน้าได้ตั้งแต่ 1 วันจนถึง 6 เดือน ขึ้นอยู่กับประเภทของทริปและความพร้อมของสถานที่ เราแนะนำให้จองล่วงหน้าอย่างน้อย 7-14 วัน เพื่อรับราคาที่ดีที่สุดและตัวเลือกที่หลากหลาย',
        ),
        FaqItem(
          question: 'สามารถยกเลิกการจองได้หรือไม่?',
          answer:
              'สามารถยกเลิกได้ตามนโยบายของแต่ละทริป โดยทั่วไป:\n• ยกเลิกก่อน 7 วัน: คืนเงิน 100%\n• ยกเลิก 3-7 วัน: คืนเงิน 50%\n• ยกเลิกภายใน 3 วัน: ไม่คืนเงิน\nกรุณาตรวจสอบข้อกำหนดเฉพาะของแต่ละทริปก่อนทำการจอง',
        ),
        FaqItem(
          question: 'สามารถเปลี่ยนวันเดินทางได้ไหม?',
          answer:
              'สามารถเปลี่ยนแปลงวันเดินทางได้ โดยแจ้งล่วงหน้าอย่างน้อย 5 วันก่อนวันเดินทาง อาจมีค่าธรรมเนียมการเปลี่ยนแปลง 500-1,000 บาท ขึ้นอยู่กับประเภทของทริป ติดต่อทีมสนับสนุนเพื่อขอเปลี่ยนแปลงได้ที่เมนูช่วยเหลือ',
        ),
        FaqItem(
          question: 'ต้องจ่ายเงินเต็มจำนวนเลยหรือไม่?',
          answer:
              'มีตัวเลือกการชำระเงิน 2 แบบ:\n1. จ่ายเต็มจำนวน: รับส่วนลดทันที 5-10%\n2. จ่ายมัดจำ 30%: ชำระส่วนที่เหลือก่อนเดินทาง 3 วัน\nคุณสามารถเลือกได้ตามความสะดวกในขั้นตอนการชำระเงิน',
        ),
      ],
    ),
    FaqCategory(
      title: 'การชำระเงิน',
      icon: Icons.payment_outlined,
      color: Colors.green,
      faqs: [
        FaqItem(
          question: 'รับชำระเงินผ่านช่องทางไหนบ้าง?',
          answer:
              'เรารับชำระเงินผ่านหลายช่องทาง:\n• บัตรเครดิต/เดบิต (Visa, Mastercard, JCB)\n• Mobile Banking\n• QR Code (PromptPay)\n• โอนเงินผ่านธนาคาร\n• TrueMoney Wallet\nทุกช่องทางปลอดภัยด้วยระบบเข้ารหัส SSL',
        ),
        FaqItem(
          question: 'มีค่าธรรมเนียมการชำระเงินหรือไม่?',
          answer:
              'ไม่มีค่าธรรมเนียมเพิ่มเติมสำหรับการชำระเงินผ่านช่องทางที่เราสนับสนุน ยกเว้นการผ่อนชำระผ่านบัตรเครดิต ซึ่งขึ้นอยู่กับเงื่อนไขของธนาคารผู้ออกบัตร',
        ),
        FaqItem(
          question: 'ใบเสร็จจะได้รับเมื่อไหร่?',
          answer:
              'ใบเสร็จอิเล็กทรอนิกส์จะถูกส่งไปยังอีเมลของคุณทันทีหลังจากชำระเงินสำเร็จ คุณสามารถดาวน์โหลดใบเสร็จได้จากหน้า "ประวัติการจอง" ในแอปพลิเคชันตลอดเวลา',
        ),
        FaqItem(
          question: 'สามารถขอใบกำกับภาษีได้ไหม?',
          answer:
              'ได้ค่ะ คุณสามารถขอใบกำกับภาษีได้โดยแจ้งข้อมูลบริษัท (ชื่อ, ที่อยู่, เลขประจำตัวผู้เสียภาษี) ก่อนหรือภายใน 7 วันหลังชำระเงิน ติดต่อทีมสนับสนุนเพื่อขอออกใบกำกับภาษี',
        ),
      ],
    ),
    FaqCategory(
      title: 'ระหว่างการเดินทาง',
      icon: Icons.luggage_outlined,
      color: Colors.orange,
      faqs: [
        FaqItem(
          question: 'มีไกด์นำเที่ยวไหม?',
          answer:
              'ทุกทริปของเรามีไกด์มืออาชีพที่ผ่านการอบรมและมีใบอนุญาต พร้อมให้ความรู้และดูแลตลอดการเดินทาง ไกด์สามารถสื่อสารได้ทั้งภาษาไทยและภาษาอังกฤษ',
        ),
        FaqItem(
          question: 'ควรเตรียมอะไรบ้างสำหรับการเดินทาง?',
          answer:
              'สิ่งที่แนะนำให้เตรียม:\n• เอกสารส่วนตัว (บัตรประชาชน, พาสปอร์ต)\n• ยาประจำตัว (ถ้ามี)\n• เสื้อผ้าที่เหมาะสมกับสภาพอากาศ\n• ครีมกันแดด และหมวก\n• กล้องถ่ายรูป\n• เงินสดสำรองสำหรับค่าใช้จ่ายส่วนตัว\nรายละเอียดเพิ่มเติมจะถูกส่งให้ก่อนการเดินทาง',
        ),
        FaqItem(
          question: 'อาหารรวมในทริปหรือไม่?',
          answer:
              'ขึ้นอยู่กับแพ็คเกจที่เลือก:\n• Full Board: รวมอาหาร 3 มื้อ\n• Half Board: รวมอาหาร 2 มื้อ (เช้า + กลางวัน/เย็น)\n• Breakfast Only: รวมอาหารเช้าอย่างเดียว\nดูรายละเอียดในหน้าแพ็คเกจของแต่ละทริป',
        ),
        FaqItem(
          question: 'ถ้าเกิดเหตุฉุกเฉินต้องติดต่อใคร?',
          answer:
              'คุณสามารถติดต่อได้ 3 ช่องทาง:\n1. ไกด์นำเที่ยวประจำทริป\n2. ฝ่ายดูแลลูกค้า 24/7: 02-xxx-xxxx\n3. แจ้งเตือนฉุกเฉินในแอปพลิเคชัน\nทีมงานของเราพร้อมช่วยเหลือตลอด 24 ชั่วโมง',
        ),
      ],
    ),
    FaqCategory(
      title: 'บัญชีและโปรไฟล์',
      icon: Icons.account_circle_outlined,
      color: Colors.purple,
      faqs: [
        FaqItem(
          question: 'ลืมรหัสผ่านต้องทำอย่างไร?',
          answer:
              'คลิกที่ "ลืมรหัสผ่าน?" ในหน้า Login แล้วกรอกอีเมลที่ใช้ลงทะเบียน ระบบจะส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณ ลิงก์จะใช้ได้เพียง 24 ชั่วโมง',
        ),
        FaqItem(
          question: 'สามารถเปลี่ยนอีเมลได้ไหม?',
          answer:
              'สามารถเปลี่ยนอีเมลได้โดยไปที่ "ตั้งค่า" > "ข้อมูลส่วนตัว" > "แก้ไขอีเมล" คุณจะต้องยืนยันอีเมลใหม่ผ่านลิงก์ที่ส่งไปให้ หลังจากนั้นอีเมลเก่าจะถูกยกเลิกการใช้งาน',
        ),
        FaqItem(
          question: 'จะลบบัญชีได้อย่างไร?',
          answer:
              'หากต้องการลบบัญชี กรุณาติดต่อฝ่ายสนับสนุนลูกค้า เนื่องจากต้องตรวจสอบการจองที่ค้างอยู่และทำการคืนเงิน (ถ้ามี) ข้อมูลทั้งหมดจะถูกลบภายใน 30 วัน',
        ),
        FaqItem(
          question: 'ข้อมูลของฉันปลอดภัยแค่ไหน?',
          answer:
              'เราใช้มาตรฐานความปลอดภัยสูงสุด:\n• เข้ารหัสข้อมูลด้วย SSL/TLS\n• ไม่เก็บข้อมูลบัตรเครดิต\n• ปฏิบัติตาม PDPA\n• ตรวจสอบความปลอดภัยสม่ำเสมอ\nข้อมูลของคุณจะไม่ถูกแชร์ให้บุคคลที่สาม',
        ),
      ],
    ),
  ];

  final List<SupportOption> _supportOptions = [
    SupportOption(
      title: 'โทรหาเรา',
      subtitle: '02-xxx-xxxx',
      icon: Icons.phone_outlined,
      color: Colors.green,
      available: true,
      hours: '08:00 - 20:00',
    ),
    SupportOption(
      title: 'ส่งอีเมล',
      subtitle: 'support@travelapp.com',
      icon: Icons.email_outlined,
      color: Colors.orange,
      available: true,
      hours: 'ตอบภายใน 24 ชม.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;

    return _faqCategories
        .map((category) {
          final filteredFaqs = category.faqs
              .where(
                (faq) =>
                    faq.question.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    faq.answer.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          return FaqCategory(
            title: category.title,
            icon: category.icon,
            color: category.color,
            faqs: filteredFaqs,
          );
        })
        .where((category) => category.faqs.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'ช่วยเหลือและสนับสนุน',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.onPrimary,
          indicatorWeight: 3,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'คำถามที่พบบ่อย'),
            Tab(text: 'ติดต่อเรา'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(colorScheme, theme),
          _buildSupportTab(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildFaqTab(ColorScheme colorScheme, ThemeData theme) {
    return Column(
      children: [
        // Search Bar
        Container(
          color: colorScheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _expandedFaqIndex = null;
              });
            },
            decoration: InputDecoration(
              hintText: 'ค้นหาคำถาม...',
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // FAQ List
        Expanded(
          child: _filteredCategories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ไม่พบคำถามที่ค้นหา',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ลองใช้คำค้นหาอื่นหรือติดต่อทีมสนับสนุน',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = _filteredCategories[categoryIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // FAQ Items
                        ...category.faqs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final faq = entry.value;
                          final globalIndex = categoryIndex * 100 + index;
                          final isExpanded = _expandedFaqIndex == globalIndex;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: colorScheme.surfaceContainerHighest,
                            elevation: isExpanded ? 4 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isExpanded
                                  ? BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedFaqIndex = isExpanded
                                      ? null
                                      : globalIndex;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            faq.question,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Divider(
                                        color: colorScheme.outlineVariant,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        faq.answer,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              height: 1.6,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSupportTab(ColorScheme colorScheme, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'เลือกช่องทางที่สะดวกสำหรับคุณ',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ทีมงานของเราพร้อมช่วยเหลือคุณตลอดเวลา',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Support Options
          ...(_supportOptions.map((option) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: colorScheme.surfaceContainerHighest,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  _handleSupportOption(context, option);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: option.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(option.icon, color: option.color, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: option.available
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        option.available
                                            ? Icons.check_circle
                                            : Icons.access_time,
                                        size: 14,
                                        color: option.available
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        option.hours,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: option.available
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList()),

          const SizedBox(height: 24),

          // Quick Tips
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'เคล็ดลับ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'ก่อนติดต่อเรา ลองตรวจสอบคำถามที่พบบ่อยก่อน คุณอาจพบคำตอบที่ต้องการได้เร็วขึ้น!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Social Media
          Text(
            'ติดตามเราได้ที่',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                context,
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
              ),
              _buildSocialButton(
                context,
                icon: Icons.chat,
                label: 'Line',
                color: const Color(0xFF00B900),
              ),
              _buildSocialButton(
                context,
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เปิด $label'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _handleSupportOption(BuildContext context, SupportOption option) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(option.icon, size: 64, color: option.color),
              const SizedBox(height: 16),
              Text(
                option.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                option.subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เปิด ${option.title}'),
                        backgroundColor: colorScheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: option.color.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ดำเนินการต่อ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Models
class FaqCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FaqItem> faqs;

  FaqCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.faqs,
  });
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class SupportOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool available;
  final String hours;

  SupportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.available,
    required this.hours,
  });
}
