import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';

class RecStatusDetailsPage extends StatefulWidget {
  const RecStatusDetailsPage({super.key});

  @override
  State<RecStatusDetailsPage> createState() => _RecStatusDetailsPageState();
}

class _RecStatusDetailsPageState extends State<RecStatusDetailsPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดสถานะ',
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
      body: const SingleChildScrollView(child: Column(children: [])),
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
