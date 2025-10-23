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

  UserModel? sender;
  UserModel? receiver;
  List<Product> products = [];
  String? senderAddress;
  String? receiverAddress;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) async {
      url = value['apiEndpoint'];
      final appData = Provider.of<AppData>(context, listen: false);
      shipmentId = appData.createdShipmentId;
      if (shipmentId != null) {
        await loadShipmentDetail();
      }
      setState(() {});
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
          'รายละเอียดการจัดส่ง',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: shipmentId == null
          ? const Center(child: Text("❌ ไม่พบข้อมูลการจัดส่ง"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧍‍♂️ ข้อมูลผู้ส่ง
                  Text(
                    '👤 ผู้ส่ง: ${sender?.name ?? "-"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text('📞 เบอร์โทร: ${sender?.phone ?? "-"}'),
                  Text('📍 ที่อยู่ผู้ส่ง: ${senderAddress ?? "-"}'),
                  const SizedBox(height: 15),

                  // 📦 ข้อมูลผู้รับ
                  Text(
                    '📦 ผู้รับ: ${receiver?.name ?? "-"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text('📞 เบอร์โทร: ${receiver?.phone ?? "-"}'),
                  Text('🏠 ที่อยู่ผู้รับ: ${receiverAddress ?? "-"}'),
                  const Divider(height: 30),
                  Text(
                    'ออเดอร์: ${shipmentId ?? "-"}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),
                  ...products.map(
                    (p) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading:
                            p.imageProduct != null && p.imageProduct!.isNotEmpty
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
                  const Text(
                    'ถ่ายรูปประกอบสถานะ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
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
            ),
    );
  }

  // ✅ โหลดข้อมูล Shipment
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

  // ✅ ฟังก์ชันส่งสินค้า
  Future<void> sendShipment() async {
    if (shipmentId == null || image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ กรุณาถ่ายรูปก่อนส่ง")));
      return;
    }

    try {
      var req = http.MultipartRequest(
        "POST",
        Uri.parse("$url/deliveryRoutes/photo"),
      );
      req.fields['shipment_id'] = shipmentId.toString();
      req.fields['status'] = "1"; // รอไรเดอร์มารับสินค้า
      req.files.add(await http.MultipartFile.fromPath("file", image!.path));

      final uploadResponse = await req.send();
      final uploadFull = await http.Response.fromStream(uploadResponse);

      if (uploadFull.statusCode == 201) {
        log("✅ อัปโหลดรูปภาพสำเร็จ");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ ส่งข้อมูลสำเร็จ")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SenderOrderStatusPage(),
          ),
        );
      } else {
        throw Exception("อัปโหลดไม่สำเร็จ: ${uploadFull.body}");
      }
    } catch (e) {
      log("❌ sendShipment error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ส่งข้อมูลไม่สำเร็จ: $e")));
    }
  }
}
