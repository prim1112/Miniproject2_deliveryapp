import 'package:flutter/material.dart';

class RiderHomepage extends StatefulWidget {
  const RiderHomepage({super.key});

  @override
  State<RiderHomepage> createState() => _RiderHomepageState();
}

class _RiderHomepageState extends State<RiderHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'หน้าหลัก',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffCC0033),
      ),
      body: SingleChildScrollView(),
    );
  }
}
