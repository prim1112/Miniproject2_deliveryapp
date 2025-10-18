import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/shipment_detail_res.dart';
import 'package:dalivery_application/model/response/user_model_get_res.dart';
import 'package:dalivery_application/pages/user/sender/sender_order_status_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dalivery_application/config/shared/app_data.dart';

class SenderOrderSummaryPage extends StatefulWidget {
  const SenderOrderSummaryPage({super.key});

  @override
  State<SenderOrderSummaryPage> createState() => _SenderOrderSummaryPageState();
}

class _SenderOrderSummaryPageState extends State<SenderOrderSummaryPage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? uploadedPhotoUrl;
  String url = "";
  int? shipmentId;

  late Future<void> loadData;
  UserModel? sender;
  UserModel? receiver;
  List<Product> products = [];
  String? senderAddress;
  String? receiverAddress;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      final appData = Provider.of<AppData>(context, listen: false);
      shipmentId = appData.createdShipmentId;

      if (shipmentId != null) {
        loadData = loadShipmentDetail();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'รายละเอียดการจัดส่ง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: shipmentId == null
          ? const Center(child: Text("❌ ไม่พบข้อมูลการจัดส่ง"))
          : FutureBuilder(
              future: loadData,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (sender == null || receiver == null) {
                  return const Center(child: Text("❌ โหลดข้อมูลไม่สำเร็จ"));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🧍‍♂️ ข้อมูลผู้ส่ง
                      Text(
                        '👤 ผู้ส่ง: ${sender!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('📞 เบอร์โทร: ${sender!.phone}'),
                      Text('📍 ที่อยู่ผู้ส่ง: ${senderAddress ?? "-"}'),
                      const SizedBox(height: 15),

                      // 📦 ข้อมูลผู้รับ
                      Text(
                        '📦 ผู้รับ: ${receiver!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('📞 เบอร์โทร: ${receiver!.phone}'),
                      Text('🏠 ที่อยู่ผู้รับ: ${receiverAddress ?? "-"}'),
                      const Divider(height: 30),

                      // รายการสินค้า
                      Text(
                        'สินค้า (${products.length} รายการ)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (products.isEmpty)
                        const Text("– ไม่มีสินค้าในรายการ –"),
                      ...products.map(
                        (p) => Card(
                          child: ListTile(
                            leading:
                                p.imageProduct != null &&
                                    p.imageProduct!.isNotEmpty
                                ? Image.network(
                                    p.imageProduct!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.inventory_2, size: 40),
                            title: Text(p.details),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ถ่ายรูปสถานะ
                      Text(
                        '📷 รูปประกอบสถานะ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          image = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          setState(() {});
                        },
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : uploadedPhotoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    uploadedPhotoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: sendShipment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            "ส่ง",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// ✅ โหลดข้อมูล Shipment ทั้งหมด (รวม sender/receiver/address/products)
  Future<void> loadShipmentDetail() async {
    final res = await http.get(
      Uri.parse("$url/deliveryRoutes/shipment/$shipmentId"),
    );
    if (res.statusCode != 200) throw Exception("โหลดไม่สำเร็จ");

    final shipment = shipmentFullDetailResFromJson(res.body);

    senderAddress = shipment.pickupAddress.addressText;
    receiverAddress = shipment.deliveryAddress.addressText;
    uploadedPhotoUrl = shipment.shipmentPhotos.isNotEmpty
        ? shipment.shipmentPhotos.last.photoUrl
        : null;

    sender = UserModel(
      userid: shipment.sender.userId,
      name: shipment.sender.name,
      phone: shipment.sender.phone,
      imageUser: shipment.sender.imageUser,
    );

    receiver = UserModel(
      userid: shipment.receiver.userId,
      name: shipment.receiver.name,
      phone: shipment.receiver.phone,
      imageUser: shipment.receiver.imageUser,
    );

    products = shipment.products;
  }

  /// ✅ อัปโหลดรูป
  Future<void> _uploadPhoto() async {
    if (image == null || shipmentId == null) return;

    var req = http.MultipartRequest(
      "POST",
      Uri.parse("$url/deliveryRoutes/photo"),
    );
    req.fields['shipment_id'] = shipmentId.toString();
    req.fields['status'] = "1";
    req.files.add(await http.MultipartFile.fromPath("file", image!.path));

    final response = await req.send();
    final full = await http.Response.fromStream(response);

    if (full.statusCode == 201) {
      final data = json.decode(full.body);
      setState(() => uploadedPhotoUrl = data['photo']['photo_url']);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ อัปโหลดรูปภาพสำเร็จ")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ อัปโหลดไม่สำเร็จ: ${full.body}")),
      );
    }
  }

  Future<void> sendShipment() async {
    if (shipmentId == null || image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ กรุณาถ่ายรูปก่อนส่ง")));
      return;
    }

    try {
      // 1️⃣ อัปโหลดรูปภาพพร้อมสถานะ 1
      var req = http.MultipartRequest(
        "POST",
        Uri.parse("$url/deliveryRoutes/photo"),
      );
      req.fields['shipment_id'] = shipmentId.toString();
      req.fields['status'] = "1"; // รอไรเดอร์มารับสินค้า
      req.files.add(await http.MultipartFile.fromPath("file", image!.path));

      final uploadResponse = await req.send();
      final uploadFull = await http.Response.fromStream(uploadResponse);

      if (uploadFull.statusCode != 201) {
        throw Exception("อัปโหลดรูปไม่สำเร็จ: ${uploadFull.body}");
      }

      log("✅ รูปอัปโหลดเรียบร้อยแล้ว (status=1)");

      // 2️⃣ แจ้งเตือนว่าทำรายการสำเร็จและกลับหน้ารายการ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ ส่งข้อมูลสำเร็จ")));

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SenderOrderStatusPage(),
          ),
        );
      });
    } catch (e) {
      log("❌ sendShipment error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ส่งข้อมูลไม่สำเร็จ: $e")));
    }
  }
}
