import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:dalivery_application/pages/user/receiver/receiver_order_tracking_page.dart';

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

  String getStatusText(dynamic status) {
    int s;
    if (status is String) {
      s = int.tryParse(status) ?? 0;
    } else {
      s = status ?? 0;
    }

    switch (s) {
      case 1:
        return "รอไรเดอร์มารับสินค้า";
      case 2:
        return "ไรเดอร์รับงานแล้ว";
      case 3:
        return "ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง";
      case 4:
        return "ไรเดอร์นำส่งสินค้าแล้ว";
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
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Order: ${shipment['shipment_id'] ?? '-'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                shipment['photo_url'] ??
                                    "https://cdn-icons-png.flaticon.com/512/3081/3081559.png",
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "👤 จาก: ${shipment['sender_name'] ?? '-'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "📞 ${shipment['sender_phone'] ?? '-'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  "📍 ต้นทาง: ${shipment['pickup_address'] ?? '-'}",
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "สถานะ: ${getStatusText(shipment['status'])}",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0A9718),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                    ),
                                    onPressed: () {
                                      final id = shipment['shipment_id'];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiverOrderTrackingPage(
                                                orderId: id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "รายละเอียด",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
