import 'package:dalivery_application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dalivery_application/pages/login.dart';
import 'package:dalivery_application/pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ สร้าง UserController และโหลดข้อมูล user จาก SharedPreferences
  final userController = Get.put(UserController());
  await userController.loadUser();

  // ✅ ตรวจสอบว่ามี userId แล้วหรือยัง
  final bool isLoggedIn = userController.userId.value.isNotEmpty;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Delivery App',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Homepage() : LoginPage(),
    );
  }
}