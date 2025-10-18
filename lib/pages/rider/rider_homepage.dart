import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';
import 'package:dalivery_application/pages/rider/bottom_navbar.dart';
import 'package:dalivery_application/pages/rider/rider_%20details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RiderHomepage extends StatefulWidget {
  const RiderHomepage({super.key});

  @override
  State<RiderHomepage> createState() => _RiderHomepageState();
}

class _RiderHomepageState extends State<RiderHomepage> {
  int selectedIndex = 0;
  List<dynamic> shipments = [];
  bool isLoading = true;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      fetchShipments();
    });
  }

  Future<void> fetchShipments() async {
    try {
      final res = await http.get(
        Uri.parse('$url/deliveryRoutes/shipments/pending'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          shipments = data['shipments'];
          isLoading = false;
        });
      } else {
        throw Exception('โหลดข้อมูลไม่สำเร็จ');
      }
    } catch (e) {
      log('❌ fetchShipments error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'รายการงานทั้งหมด',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shipments.isEmpty
          ? const Center(child: Text('ยังไม่มีงานให้รับ'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: shipments.length,
              itemBuilder: (context, index) {
                final s = shipments[index];
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
                              "Order : ${s['shipment_id']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                s['photo_url'],
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
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("👤 ${s['receiver_name']}"),
                                Text("📞 ${s['receiver_phone']}"),
                                Text("📍 ${s['address']}"),

                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xfff0A9718),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RiderDetails(
                                            shipment:
                                                s, // ✅ ส่งข้อมูล shipment ทั้ง object ไปหน้าใหม่
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "รายละเอียด",
                                      style: TextStyle(color: Colors.white),
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
      bottomNavigationBar: MainBottomNavRider(
        selectedIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        screenSize: MediaQuery.of(context).size,
        onDestinationSelected: (_) {},
      ),
    );
  }
}
