import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/pages/user/sender/sender_order_status_page.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:dalivery_application/model/response/user_model_get_res.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dalivery_application/config/config.dart';

class SenderOrderSummaryPage extends StatefulWidget {
  final String shipmentId;
  final UserModel sender;
  final UserModel receiver;
  final List<Map<String, dynamic>> products;

  const SenderOrderSummaryPage({
    super.key,
    required this.shipmentId,
    required this.sender,
    required this.receiver,
    required this.products,
  });

  @override
  State<SenderOrderSummaryPage> createState() => _SenderOrderSummaryPageState();
}

class _SenderOrderSummaryPageState extends State<SenderOrderSummaryPage> {
  int selectedIndex = 0;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? uploadedPhotoUrl; // ✅ เก็บ URL รูปที่อัพโหลดแล้ว

  String apiEndpoint = ""; // ✅ เพิ่มตัวแปรเก็บ endpoint

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      log("API ENDPOINT: ${value['apiEndpoint']}");
      setState(() {
        apiEndpoint = value['apiEndpoint'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'ผู้ส่งถ่ายรูปประกอบสถานะ',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ข้อมูลผู้ส่ง
            Text(
              'Sender : ${widget.sender.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Phone : ${widget.sender.phone}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Address : ${widget.sender.addresses.isNotEmpty ? widget.sender.addresses.first.addressText : "-"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 16),
            Container(width: 300, height: 2, color: Colors.black),
            const SizedBox(height: 16),

            // ✅ ข้อมูลผู้รับ
            Text(
              'Receiver : ${widget.receiver.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Phone : ${widget.receiver.phone}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Address : ${widget.receiver.addresses.isNotEmpty ? widget.receiver.addresses.first.addressText : "-"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 16),
            Container(width: 300, height: 2, color: Colors.black),
            const SizedBox(height: 16),

            // ✅ รายการสินค้า
            Text(
              'Order : ${widget.products.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.products.map((p) {
                return Text(
                  p['details'] ?? '',
                  style: const TextStyle(fontSize: 16),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // ✅ ถ่ายรูปประกอบสถานะ
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ถ่ายรูปประกอบสถานะ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      log("📸 Image captured: ${image!.path}");
                      setState(() {});
                    } else {
                      log('No Image');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: uploadedPhotoUrl != null
                        // ✅ แสดงรูปจาก Cloudinary ถ้าอัปโหลดสำเร็จ
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.network(
                              uploadedPhotoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : image != null
                        // ✅ แสดงรูปที่เพิ่งถ่ายมา ถ้ายังไม่อัปโหลด
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.file(
                              File(image!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        // ✅ ยังไม่ถ่ายรูป → แสดงปุ่ม Add
                        : const Center(child: Icon(Icons.add, size: 50)),
                  ),
                ),

                // ✅ ปุ่มยืนยันรูปภาพ (อัปโหลดไป Firebase)
                if (image != null && uploadedPhotoUrl == null) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        var request = http.MultipartRequest(
                          "POST",
                          Uri.parse(
                            "$apiEndpoint/shipment_photos/ShipmentPhoto",
                          ),
                        );
                        request.fields['shipment_id'] = widget.shipmentId;
                        request.fields['status'] = "1";
                        request.files.add(
                          await http.MultipartFile.fromPath(
                            "file",
                            image!.path,
                          ),
                        );

                        try {
                          final streamedRes = await request.send();
                          final res = await http.Response.fromStream(
                            streamedRes,
                          );
                          if (res.statusCode == 201) {
                            final data = json.decode(res.body);
                            setState(() {
                              uploadedPhotoUrl = data['photo']['photo_url'];
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("อัปโหลดรูปสถานะสำเร็จ"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("ผิดพลาด: ${res.body}")),
                            );
                          }
                        } catch (e) {
                          log("❌ Error upload photo: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "ยืนยันรูปภาพ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 100),

            // ✅ ปุ่มส่ง
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (uploadedPhotoUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("กรุณาถ่ายรูปและยืนยันก่อนส่ง"),
                      ),
                    );
                    return;
                  }
                  _showConfirmDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  'ส่ง',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
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

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ยืนยันการส่งสินค้า',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC0033),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'ย้อนกลับ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SenderOrderStatusPage(
                              shipmentId: widget.shipmentId,
                              sender: widget.sender,
                              receiver: widget.receiver,
                              products: widget.products,
                              status: 1,
                              photoUrl: uploadedPhotoUrl,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0033),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
