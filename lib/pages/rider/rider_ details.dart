import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';

class RiderDetails extends StatefulWidget {
  final Map<String, dynamic> shipment; // ✅ รับ shipment จากหน้าแรก

  const RiderDetails({super.key, required this.shipment});

  @override
  State<RiderDetails> createState() => _RiderDetailsState();
}

class _RiderDetailsState extends State<RiderDetails> {
  String url = '';
  List<dynamic> productImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    try {
      final shipmentId = widget.shipment['shipment_id'];
      final res = await http.get(
        Uri.parse('$url/deliveryRoutes/products/byShipment/$shipmentId'),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          productImages = data['products'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('โหลดสินค้าไม่สำเร็จ');
      }
    } catch (e) {
      log("❌ fetchProducts error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> acceptShipment() async {
    final appData = Provider.of<AppData>(context, listen: false);
    final riderId = appData.userProfile.user_id;
    final shipmentId = widget.shipment['shipment_id'];

    try {
      final res = await http.put(
        Uri.parse('$url/deliveryRoutes/shipments/$shipmentId/accept'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'rider_id': riderId}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ รับงานสำเร็จ")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ รับงานไม่สำเร็จ: ${res.statusCode}")),
        );
      }
    } catch (e) {
      log("❌ acceptShipment error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          "รายละเอียดงาน",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "👤 Name : ${s['receiver_name']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "📞 Phone : ${s['receiver_phone']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "📍 Address : ${s['address']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 30),
                  Text(
                    "Order : ${s['shipment_id']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("รายการสินค้า :", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  // ✅ แสดงรูปสินค้าจาก products
                  if (productImages.isEmpty)
                    const Center(
                      child: Text(
                        "ไม่มีรูปสินค้า",
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: productImages.length,
                        itemBuilder: (context, index) {
                          final p = productImages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🖼️ รูปสินค้า (ซ้าย)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    p['image_product'] ??
                                        "https://cdn-icons-png.flaticon.com/512/3081/3081559.png",
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 📄 รายละเอียดสินค้า (ขวา)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['details'] ?? 'ไม่ระบุรายละเอียด',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: acceptShipment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "รับงาน",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
