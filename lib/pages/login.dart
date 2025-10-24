import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/model/request/user_login_post_req.dart';
import 'package:dalivery_application/model/response/user_login_get_res.dart';
import 'package:dalivery_application/pages/user/sender/home_sender.dart';
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
import 'package:dalivery_application/pages/sender_or_receiver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dalivery_application/config/config.dart';
import 'package:get/get.dart';
import 'package:dalivery_application/providers/user_provider.dart';

// ✅ เพิ่ม 2 import สำหรับ Provider
import 'package:provider/provider.dart';
import 'package:dalivery_application/providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final userController = Get.find<UserController>();

  String? apiEndpoint;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      log("API ENDPOINT: ${value['apiEndpoint']}");
      apiEndpoint = value['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 2, 2),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFCC0033),
            padding: const EdgeInsets.only(top: 40, left: 10),
            height: 80,
            width: double.infinity,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: screenHeight * 0.9,
              decoration: const BoxDecoration(color: Color(0xfffafafa)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Phone
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'เบอร์โทรศัพท์',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCC0033),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCC0033),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'รหัสผ่าน',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCC0033),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCC0033),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: 180,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC0033),
                            shape: const StadiumBorder(),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'เข้าสู่ระบบ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'หากยังไม่เป็นสมาชิกให้',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SenderOrRiderPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'สมัครสมาชิก',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCC0033),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    final loginUrl = Uri.parse("$apiEndpoint/user/login");
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกเบอร์โทรและรหัสผ่าน")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final req = UsersLoginPostRequest(phone: phone, password: password);

      final response = await http.post(
        loginUrl,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: usersLoginPostRequestToJson(req),
      );

      log("Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);

        // ✅ ตรวจว่าเป็น user หรือ rider
        final role = jsonRes["role"];

        if (role == "user") {
          final userid = jsonRes["id"];
          final username = jsonRes["name"];
          log("User login success: $username, id: $userid");

          // ✅ บันทึกข้อมูลใน GetX Controller
          await userController.saveUser(userid.toString(), username);

          // ไปหน้า SenderPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SenderPage()),
          );
        } else if (role == "rider") {
          final riderid = jsonRes["rider_id"];
          final ridername = jsonRes["name"];
          log("Rider login success: $ridername, id: $riderid");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RiderHomepage()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("ไม่พบข้อมูลผู้ใช้")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      log("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อ")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
