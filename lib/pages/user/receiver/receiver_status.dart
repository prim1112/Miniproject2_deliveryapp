import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RecStatusPage extends StatefulWidget {
  const RecStatusPage({super.key});

  @override
  State<RecStatusPage> createState() => _RecStatusPageState();
}

class _RecStatusPageState extends State<RecStatusPage> {
  int selectedIndex = 0;
  List<dynamic> shipments = [];
  bool isLoading = true;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig()
        .then((value) {
          url = value['apiEndpoint'];
          fetchShipmentsByReceiver();
        })
        .catchError((err) {
          log("❌ Config error: ${err.toString()}");
          setState(() => isLoading = false);
        });
  }

  /// ✅ โหลด shipment ทั้งหมดที่ "เราคือผู้รับ"
  Future<void> fetchShipmentsByReceiver() async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);
      final receiverId = appData.userProfile.user_id;

      log("🔎 โหลดข้อมูล shipment ของ receiver_id: $receiverId");
      final response = await http.get(
        Uri.parse("$url/deliveryRoutes/shipments/byReceiver/$receiverId"),
      );

      if (response.statusCode == 200) {
        setState(() {
          shipments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลไม่สำเร็จ");
      }
    } catch (e) {
      log("❌ fetchShipmentsByReceiver error: $e");
      setState(() => isLoading = false);
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case "pending":
        return "รอไรเดอร์มารับสินค้า";
      case "accepted":
        return "ไรเดอร์รับงานแล้ว";
      case "picked_up":
        return "กำลังจัดส่ง";
      case "delivered":
        return "จัดส่งสำเร็จ";
      default:
        return "ไม่ทราบสถานะ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'รายการสินค้าที่คุณต้องรับ',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shipments.isEmpty
          ? const Center(child: Text("ยังไม่มีสินค้าที่ต้องรับ"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: shipments.length,
              itemBuilder: (context, index) {
                final shipment = shipments[index];
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ รูปภาพสถานะ
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            shipment['photo_url'] ??
                                "https://cdn-icons-png.flaticon.com/512/3081/3081559.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ✅ รายละเอียดผู้ส่ง
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "จาก: ${shipment['sender_name'] ?? '-'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "เบอร์โทร: ${shipment['sender_phone'] ?? '-'}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "ต้นทาง: ${shipment['pickup_address'] ?? '-'}",
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    "สถานะ: ",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    getStatusText(shipment['status']),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
      ),
    );
  }
}
