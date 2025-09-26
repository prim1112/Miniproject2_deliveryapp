import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/internal_config.dart';
import 'package:dalivery_application/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/request/user_register_post_req.dart';
import 'package:dalivery_application/pages/sender_or_receiver.dart';
import 'package:dalivery_application/pages/user/user_search_address.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  ImagePicker picker = ImagePicker();
  XFile? image;
  String text = '';
  TextEditingController name = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController image_user = TextEditingController();
  TextEditingController password = TextEditingController();
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
                'รูปภาพ',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: image_user,
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
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        log(image.path.toString());
                        setState(() {
                          image_user.text = image.path;
                        });
                      } else {
                        log('No Image');
                      }
                    },
                  ),
                ],
              ),

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
    if (name.text.trim().isEmpty ||
        phoneCtl.text.trim().isEmpty ||
        password.text.isEmpty ||
        image_user.text.isEmpty) {
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
      log("Sending request to $apiEndpoint/user/register-user");

      var data = UserRegisterPostRequest(
        name: name.text.trim(),
        phone: phoneCtl.text.trim(),
        password: password.text,
        imageUser: image_user.text,
      );

      final response = await http.post(
        Uri.parse('$apiEndpoint/user/register-user'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: userRegisterPostRequestToJson(data),
      );

      log("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> resData = jsonDecode(response.body);

        if (resData['message'] == "Phone number already exists") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('หมายเลขโทรศัพท์นี้ถูกใช้ไปแล้ว')),
          );
          return;
        }

        final int userid = resData['user']['userid'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchAddressPage(userid: userid),
          ),
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
