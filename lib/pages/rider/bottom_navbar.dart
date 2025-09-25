import 'package:dalivery_application/test.dart';
import 'package:flutter/material.dart';

class MainBottomNavRider extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const MainBottomNavRider({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required Size screenSize,
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
              MaterialPageRoute(builder: (context) => const testpage()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const testpage()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const testpage()),
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
          icon: Icon(Icons.notifications_active_outlined),
          label: 'สถานะ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout_outlined),
          label: 'ออกจากระบบ',
        ),
      ],
    );
  }
}
