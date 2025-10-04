import 'package:flutter/material.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart'; 

class ReceiverOrderTrackingPage extends StatefulWidget {
  const ReceiverOrderTrackingPage({super.key});

  @override
  State<ReceiverOrderTrackingPage> createState() =>
      _ReceiverOrderTrackingPageState();
}

class _ReceiverOrderTrackingPageState extends State<ReceiverOrderTrackingPage> {
  final Color customRed = const Color(0xFFCC0033);

  // ตัวแปรสำหรับเก็บ index ของ bottom nav
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: customRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                'assets/images/แมพ.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildTimelineItem(
                    "รอไรเดอร์มารับสินค้า",
                    "assets/images/don.webp",
                    isLast: false,
                  ),
                  _buildTimelineItem("ไรเดอร์รับงาน", null, isLast: false),
                  _buildTimelineItem(
                    "ไรเดอร์รับสินค้าแล้วและกำลังเดินทาง",
                    null,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    "ไรเดอร์นำส่งสินค้าแล้ว",
                    "assets/images/ส่งของ.png",
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // เพิ่ม BottomNavigationBar
      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }

  Widget _buildTimelineItem(String text, String? imagePath,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // วงกลม + เส้นเชื่อม
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.black),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80, 
                color: Colors.grey.shade400,
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                if (imagePath != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      imagePath,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
