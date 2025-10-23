import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:dalivery_application/pages/user/receiver/receiver_order_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SenderOrderStatusPage extends StatefulWidget {
  const SenderOrderStatusPage({super.key});

  @override
  State<SenderOrderStatusPage> createState() => _SenderOrderStatusPageState();
}

class _SenderOrderStatusPageState extends State<SenderOrderStatusPage> {
  int selectedIndex = 0;
  List<dynamic> shipments = [];
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      final appData = Provider.of<AppData>(context, listen: false);
      fetchShipmentsBySender(appData.userProfile.user_id);
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
          'รายการส่งสินค้าของคุณ',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...shipments.map((shipment) {
              return Card(
                elevation: 4,
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
                                "👤 ${shipment['receiver_name'] ?? '-'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "📞 ${shipment['receiver_phone'] ?? '-'}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                "📍 ${shipment['delivery_address'] ?? '-'}",
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
            }),
          ],
        ),
      ),

      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
      ),
    );
  }

  Future<void> fetchShipmentsBySender(int senderId) async {
    try {
      final res = await http.get(
        Uri.parse("$url/deliveryRoutes/shipments/bySender/$senderId"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => shipments = data);
      }
    } catch (e) {
      log("❌ fetchShipmentsBySender error: $e");
    }
  }

  String getStatusText(dynamic status) {
    final s = int.tryParse(status.toString()) ?? 0;
    switch (s) {
      case 1:
        return "รอไรเดอร์มารับสินค้า";
      case 2:
        return "ไรเดอร์รับงานแล้ว";
      case 3:
        return "ไรเดอร์กำลังเดินทางไปส่ง";
      case 4:
        return "ไรเดอร์ส่งสินค้าแล้ว";
      default:
        return "ไม่ทราบสถานะ";
    }
  }
}
