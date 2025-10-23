import 'package:dalivery_application/pages/homepage.dart';
import 'package:dalivery_application/pages/rider/gpsmap.dart';
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
import 'package:flutter/material.dart';

class MainBottomNavRider extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final int? currentOrderId; // ✅ เพิ่มตัวแปรเก็บ order id

  const MainBottomNavRider({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required Size screenSize,
    required Null Function(int index) onDestinationSelected,
    this.currentOrderId,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) async {
        onTap(index);
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiderHomepage()),
            );
            break;

          case 1:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
              (route) => false,
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
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.notifications_active_outlined),
        //   label: 'สถานะ',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout_outlined),
          label: 'ออกจากระบบ',
        ),
      ],
    );
  }
}
