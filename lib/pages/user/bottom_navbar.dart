import 'package:dalivery_application/pages/user/receiver/receiver_status.dart';
import 'package:dalivery_application/pages/user/sender/sender_homepage.dart';
import 'package:flutter/material.dart';
import 'package:dalivery_application/pages/user/sender/sender_order_status_page.dart';
import 'package:dalivery_application/pages/homepage.dart';

class MainBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const MainBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) async {
        onTap(index); // ✅ อัปเดต selectedIndex ใน state หลัก

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SenderPage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SenderOrderStatusPage(),
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RecStatusPage()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF393939),
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'หน้าแรก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'สถานะคนส่ง',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active_outlined),
          label: 'สถานะคนรับ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout_outlined),
          label: 'ออกจากระบบ',
        ),
      ],
    );
  }
}
