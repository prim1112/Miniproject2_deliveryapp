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
  const RiderHomepage({Key? key});

  @override
  State<RiderHomepage> createState() => _RiderHomepageState();
}

class _RiderHomepageState extends State<RiderHomepage> {
  int selectedIndex = 0;
  List<dynamic> shipments = [];
  bool isLoading = true;
  String url = '';
  int? currentOrderId;

  @override
  void initState() {
    super.initState();
    _loadConfigAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final String riderName = appData.userProfile.name;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFCC0033),
        title: Text(
          'หน้าหลักคนส่ง  ($riderName)',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                                      backgroundColor: const Color(0xfff0A9718),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RiderDetails(shipment: s),
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
        currentOrderId: currentOrderId,
      ),
    );
  }

  Future<void> _loadConfigAndFetch() async {
    try {
      final value = await Configuration.getConfig();
      setState(() {
        url = value['apiEndpoint'];
      });

      log("🌐 URL Loaded in RiderHomepage: $url");

      final appData = Provider.of<AppData>(context, listen: false);
      final int riderId = appData.userProfile.user_id;

      await fetchShipments(riderId);
    } catch (e) {
      log('❌ loadConfig error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchShipments(int riderId) async {
    if (url.isEmpty) {
      log('⚠️ URL ยังไม่ถูกโหลดจาก config');
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('$url/deliveryRoutes/shipments/pending'),
      );
      log("📡 GET $url/deliveryRoutes/shipments/pending");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          shipments = data['shipments'];
          isLoading = false;
        });
        log("✅ โหลดข้อมูล shipment สำเร็จ (${shipments.length} งาน)");
      } else {
        log('⚠️ โหลดข้อมูลไม่สำเร็จ: ${res.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      log('❌ fetchShipments error: $e');
      setState(() => isLoading = false);
    }
  }
}
