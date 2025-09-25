import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';

class RecStatusPage extends StatefulWidget {
  const RecStatusPage({super.key});

  @override
  State<RecStatusPage> createState() => _RecStatusPageState();
}

class _RecStatusPageState extends State<RecStatusPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สถานะผู้รับ',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffCC0033),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(children: [Text("หน้านี้คือ RecStatusPage")]),
      ),
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
}
