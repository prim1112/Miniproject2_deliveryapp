import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';

class SenderOrderStatusPage extends StatefulWidget {
  const SenderOrderStatusPage({super.key});

  @override
  State<SenderOrderStatusPage> createState() => _SenderOrderStatusPageState();
}

class _SenderOrderStatusPageState extends State<SenderOrderStatusPage> {
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
          fetchShipmentsBySender();
        })
        .catchError((err) {
          log("❌ Config error: ${err.toString()}");
          setState(() => isLoading = false);
        });
  }

  Future<void> fetchShipmentsBySender() async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);
      final senderId = appData.userProfile.user_id;

      log("🔎 โหลดข้อมูล shipment ของ sender_id: $senderId");
      final response = await http.get(
        Uri.parse("$url/deliveryRoutes/shipments/bySender/$senderId"),
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
      log("❌ fetchShipmentsBySender error: $e");
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
          'รายการส่งสินค้าของคุณ',
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
          ? const Center(child: Text("ยังไม่มีรายการส่งสินค้า"))
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
                        // ✅ รายละเอียดคนรับ
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipment['receiver_name'] ?? "-",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "เบอร์โทร: ${shipment['receiver_phone'] ?? '-'}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "ที่อยู่: ${shipment['delivery_address'] ?? '-'}",
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
