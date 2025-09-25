import 'package:dalivery_application/pages/rider/rider_register.dart';
import 'package:dalivery_application/pages/user/user_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SenderOrRiderPage extends StatefulWidget {
  const SenderOrRiderPage({super.key});

  @override
  State<SenderOrRiderPage> createState() => _SenderOrRiderPageState();
}

class _SenderOrRiderPageState extends State<SenderOrRiderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'ผู้ใช้',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffCC0033),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Get.to(() => const UserRegisterPage());
        //   },
        // ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 40, bottom: 60),
              child: Text(
                'ท่านสนใจสมัครสมาชิกเป็น',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 150,
              height: 170,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const UserRegisterPage());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: Color(0xffffCDD2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ผู้ใช้',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/approval.png',
                      width: 150,
                      height: 120,
                    ),
                    SizedBox(width: 1),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 150,
              height: 170,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const RiderRegisterPage());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: Color(0xffFDEBC9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ไรเดอร์',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/parcel.png',
                      width: 150,
                      height: 120,
                    ),
                    SizedBox(width: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
