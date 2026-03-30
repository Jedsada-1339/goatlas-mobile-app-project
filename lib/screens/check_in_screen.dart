import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/place_model.dart';
import '../utills/firebase_service.dart';

class CheckInScreen extends StatefulWidget {
  final PlaceModel place;

  const CheckInScreen({Key? key, required this.place}) : super(key: key);

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isCheckingIn = false;

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // ลดขนาดรูปเพื่อความรวดเร็ว
    );
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<void> _checkIn() async {
    if (_imageFile == null) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      // สุ่มคะแนน 100+ (เช่น 100-999)
      final randomPoints = 100 + Random().nextInt(900);
      
      await FirebaseService().updatePoints(randomPoints);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เช็คอินสำเร็จ! คุณได้รับ $randomPoints คะแนน'),
          backgroundColor: Colors.green,
        ),
      );
      // คืนค่า true ให้หน้าทริปทราบว่าสำเร็จ เพื่อทำเครื่องหมาย Visit
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('เช็คอิน - ${widget.place.name}'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: colorScheme.onPrimaryContainer, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'LOCATION CHALLENGE',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Main Title
              Text(
                'ถ่ายรูปคู่กับสถานที่เพื่อรับ\nคะแนน',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'บันทึกความทรงจำที่${widget.place.name} พร้อมรับแต้ม\nสะสมพิเศษเพื่อแลกของรางวัล',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // กรอบรูป
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageFile != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            // รูปถ่าย
                            Image.file(
                              _imageFile!,
                              width: 300,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                            // รูปกรอบทับด้านบน
                            IgnorePointer(
                              child: Image.asset(
                                'assets/frame.png',
                                width: 300,
                                height: 400,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // กรณีไม่มีไฟล์ assets/frame.png ให้ขึ้นกรอบชั่วคราว
                                  return Container(
                                    width: 300,
                                    height: 400,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 15,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          'Go Atlas - ${widget.place.name}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: 300,
                            height: 400,
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'ยังไม่ได้ถ่ายรูป',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'แตะที่นี่หรือปุ่มด้านล่างเพื่อเปิดกล้อง',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              if (_imageFile == null)
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('ถ่ายรูปเลย!'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isCheckingIn ? null : _takePhoto,
                      icon: const Icon(Icons.refresh),
                      label: const Text('ถ่ายใหม่'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isCheckingIn ? null : _checkIn,
                      icon: _isCheckingIn 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            ) 
                          : const Icon(Icons.check_circle),
                      label: Text(_isCheckingIn ? 'กำลังบันทึก...' : 'ยืนยันเช็คอิน'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
