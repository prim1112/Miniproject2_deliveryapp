import 'dart:convert';
import 'dart:developer';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
=======
import 'package:dalivery_application/pages/login.dart';
>>>>>>> Stashed changes
=======
import 'package:dalivery_application/pages/login.dart';
>>>>>>> Stashed changes
=======
import 'package:dalivery_application/pages/login.dart';
>>>>>>> Stashed changes
import 'package:http/http.dart' as http;

import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/internal_config.dart';
import 'package:dalivery_application/model/request/rider_register_post_req.dart';
import 'package:dalivery_application/pages/sender_or_receiver.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RiderRegisterPage extends StatefulWidget {
  const RiderRegisterPage({super.key});

  @override
  State<RiderRegisterPage> createState() => _RiderRegisterPageState();
}

class _RiderRegisterPageState extends State<RiderRegisterPage> {
  ImagePicker picker = ImagePicker();
  XFile? riderImage;
  XFile? vehicleImage;
  TextEditingController name = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController licensePlateCtl = TextEditingController();
  TextEditingController riderImageCtl = TextEditingController();
  TextEditingController vehicleImageCtl = TextEditingController();
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig()
        .then((value) {
          url = value['apiEndpoint'];
          log(value['apiEndpoint']);
        })
        .catchError((err) {
          log(err.toString());
        });
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SenderOrRiderPage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 80, top: 20, bottom: 20),
                child: Text(
                  'สมัครสมาชิก',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'ชื่อ นามสกุล',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextField(
                controller: name,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'เบอร์โทร',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextField(
                controller: phoneCtl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'รูปภาพไรเดอร์',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: riderImageCtl,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.red,
                    ),
                    iconSize: 40,
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          riderImageCtl.text = image.path;
                        });
                      }
                    },
                  ),
                ],
              ),
              Text(
                'รูปภาพยาพาหนะ',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vehicleImageCtl,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.red,
                    ),
                    iconSize: 40,
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          vehicleImageCtl.text = image.path;
                        });
                      }
                    },
                  ),
                ],
              ),
              Text(
                'ทะเบียนรถ',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextField(
                controller: licensePlateCtl,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 15),

              SizedBox(height: 15),
              Text(
                'รหัสผ่าน',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 100),
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Color(0xffCC0033),
                  ),
                  child: Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      color: Color(0xFFFAFAFA),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('หากมีบัญชีอยู่แล้ว', style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 14, color: Color(0xffCC0033)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void register() async {
    if (name.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        password.text.isEmpty ||
        riderImageCtl.text.isEmpty ||
        vehicleImageCtl.text.isEmpty ||
        licensePlateCtl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }

    if (phoneCtl.text.length < 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phoneCtl.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('หมายเลขโทรศัพท์ไม่ถูกต้อง')));
      return;
    }

    if (password.text.contains(' ')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('รหัสผ่านห้ามมีช่องว่าง')));
      return;
    }

    try {
      var data = RiderRegisterPostRequest(
        name: name.text.trim(),
        phone: phoneCtl.text.trim(),
        password: password.text,
        imageRider: riderImageCtl.text,
        imageVehicle: vehicleImageCtl.text,
        licensePlate: licensePlateCtl.text.trim(),
      );
      final response = await http.post(
        Uri.parse('$apiEndpoint/rider/register-rider'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: riderRegisterPostRequestToJson(data),
      );

      log("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        if (resData['message'] == "Phone number already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('หมายเลขโทรศัพท์นี้ถูกใช้ไปแล้ว')),
          );
          return;
        }

        final int riderId = resData['rider']['rider_id'];

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiderHomepage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลงทะเบียนไม่สำเร็จ: ${response.body}')),
        );
      }
    } catch (err) {
      log("Error: $err");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $err")));
    }
  }
}
