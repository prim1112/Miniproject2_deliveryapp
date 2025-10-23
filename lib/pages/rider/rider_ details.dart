import 'package:dalivery_application/config/internal_config.dart';
import 'package:dalivery_application/pages/rider/bottom_navbar.dart';
import 'package:dalivery_application/pages/rider/gpsmap.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  int? currentOrderId;
  int selectedIndex = 0;
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
      bottomNavigationBar: MainBottomNavRider(
        selectedIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        screenSize: MediaQuery.of(context).size,
        onDestinationSelected: (_) {},
        currentOrderId: currentOrderId, // ✅ ส่ง order ปัจจุบันเข้ามา
      ),
    );
  }

  Future<void> fetchProducts() async {
    try {
      final shipmentId = widget.shipment['shipment_id'];
      final res = await http.get(
        Uri.parse(
          '$apiEndpoint/deliveryRoutes/products/byShipment/$shipmentId',
        ),
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
        Uri.parse('$apiEndpoint/deliveryRoutes/shipments/$shipmentId/accept'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'rider_id': riderId}),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ รับงานสำเร็จ")));

        // ✅ ไปหน้า GPSandMapPage ทันที
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GPSandMapPage(
              orderId: shipmentId, // ส่ง shipment_id ไปให้หน้า GPSandMapPage
            ),
          ),
        );
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

  // Future<void> acceptShipment() async {
  //   final appData = Provider.of<AppData>(context, listen: false);
  //   final riderId = appData.userProfile.user_id;
  //   final shipmentId = widget.shipment['shipment_id'];

  //   try {
  //     //
  //     LocationPermission permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.deniedForever) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("❌ กรุณาเปิดการเข้าถึงตำแหน่ง")),
  //       );
  //       return;
  //     }

  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     // ✅ ส่งข้อมูลไปพร้อม rider_id + lat/long
  //     final res = await http.put(
  //       Uri.parse('$apiEndpoint/deliveryRoutes/shipments/$shipmentId/accept'),
  //       headers: {'Content-Type': 'application/json; charset=utf-8'},
  //       body: jsonEncode({
  //         'rider_id': riderId,
  //         'rider_latitude': position.latitude,
  //         'rider_longitude': position.longitude,
  //       }),
  //     );

  //     if (res.statusCode == 200) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("✅ รับงานสำเร็จ")));

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => GPSandMapPage(orderId: shipmentId),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("❌ รับงานไม่สำเร็จ: ${res.statusCode}")),
  //       );
  //     }
  //   } catch (e) {
  //     log("❌ acceptShipment error: $e");
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
  //   }
  // }
}

// import 'package:dalivery_application/config/internal_config.dart';
// import 'package:dalivery_application/pages/rider/bottom_navbar.dart';
// import 'package:dalivery_application/pages/rider/gpsmap.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:developer';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:dalivery_application/config/config.dart';
// import 'package:dalivery_application/config/shared/app_data.dart';

// class RiderDetails extends StatefulWidget {
//   final Map<String, dynamic> shipment; // ✅ รับ shipment จากหน้าแรก

//   const RiderDetails({super.key, required this.shipment});

//   @override
//   State<RiderDetails> createState() => _RiderDetailsState();
// }

// class _RiderDetailsState extends State<RiderDetails> {
//   int? currentOrderId;
//   int selectedIndex = 0;
//   String url = '';
//   List<dynamic> productImages = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     Configuration.getConfig().then((value) {
//       url = value['apiEndpoint'];
//       fetchProducts();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final s = widget.shipment;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xffCC0033),
//         title: const Text(
//           "รายละเอียดงาน",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "👤 Name : ${s['receiver_name']}",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     "📞 Phone : ${s['receiver_phone']}",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     "📍 Address : ${s['address']}",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const Divider(height: 30),
//                   Text(
//                     "Order : ${s['shipment_id']}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text("รายการสินค้า :", style: TextStyle(fontSize: 16)),
//                   const SizedBox(height: 10),

//                   // ✅ แสดงรูปสินค้าจาก products
//                   if (productImages.isEmpty)
//                     const Center(
//                       child: Text(
//                         "ไม่มีรูปสินค้า",
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     )
//                   else
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: productImages.length,
//                         itemBuilder: (context, index) {
//                           final p = productImages[index];
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 6.0),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: Image.network(
//                                     p['image_product'] ??
//                                         "https://cdn-icons-png.flaticon.com/512/3081/3081559.png",
//                                     height: 60,
//                                     width: 60,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     p['details'] ?? 'ไม่ระบุรายละเอียด',
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                   const SizedBox(height: 10),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: acceptShipment,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 60,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: const Text(
//                         "รับงาน",
//                         style: TextStyle(fontSize: 16, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//       bottomNavigationBar: MainBottomNavRider(
//         selectedIndex: selectedIndex,
//         onTap: (index) => setState(() => selectedIndex = index),
//         screenSize: MediaQuery.of(context).size,
//         onDestinationSelected: (_) {},
//         currentOrderId: currentOrderId,
//       ),
//     );
//   }

//   Future<void> fetchProducts() async {
//     try {
//       final shipmentId = widget.shipment['shipment_id'];
//       final res = await http.get(
//         Uri.parse(
//           '$apiEndpoint/deliveryRoutes/products/byShipment/$shipmentId',
//         ),
//       );

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         setState(() {
//           productImages = data['products'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         throw Exception('โหลดสินค้าไม่สำเร็จ');
//       }
//     } catch (e) {
//       log("❌ fetchProducts error: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   /// ✅ อัปเดตใหม่ — ตรวจระยะห่างก่อนรับงาน
//   Future<void> acceptShipment() async {
//     final appData = Provider.of<AppData>(context, listen: false);
//     final riderId = appData.userProfile.user_id;
//     final shipmentId = widget.shipment['shipment_id'];

//     try {
//       // ขอสิทธิ์เข้าถึงตำแหน่ง
//       LocationPermission permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ กรุณาเปิดการเข้าถึงตำแหน่ง")),
//         );
//         return;
//       }

//       // ตำแหน่งปัจจุบันของไรเดอร์
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       // พิกัดจุดรับสินค้า (จาก shipment)
//       final pickupLat =
//           double.tryParse(widget.shipment['pickup_latitude'].toString()) ?? 0;
//       final pickupLng =
//           double.tryParse(widget.shipment['pickup_longitude'].toString()) ?? 0;

//       // พิกัดจุดส่งสินค้า
//       final deliveryLat =
//           double.tryParse(widget.shipment['delivery_latitude'].toString()) ?? 0;
//       final deliveryLng =
//           double.tryParse(widget.shipment['delivery_longitude'].toString()) ??
//           0;

//       // ✅ คำนวณระยะห่าง (เมตร)
//       final distanceToPickup = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         pickupLat,
//         pickupLng,
//       );

//       final distanceToDelivery = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         deliveryLat,
//         deliveryLng,
//       );

//       log("📍 Distance to Pickup: ${distanceToPickup.toStringAsFixed(2)} m");
//       log(
//         "📍 Distance to Delivery: ${distanceToDelivery.toStringAsFixed(2)} m",
//       );

//       // ✅ ตรวจเงื่อนไข if–else ว่าต้องไม่เกิน 20 เมตร
//       if (distanceToPickup <= 20 || distanceToDelivery <= 20) {
//         // ผ่าน ✅ สามารถรับงานได้
//         final res = await http.put(
//           Uri.parse('$apiEndpoint/deliveryRoutes/shipments/$shipmentId/accept'),
//           headers: {'Content-Type': 'application/json; charset=utf-8'},
//           body: jsonEncode({
//             'rider_id': riderId,
//             'rider_latitude': position.latitude,
//             'rider_longitude': position.longitude,
//           }),
//         );

//         if (res.statusCode == 200) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("✅ รับงานสำเร็จ")));

//           // ไปหน้า GPS ติดตามแบบเรียลไทม์
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => GPSandMapPage(orderId: shipmentId),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("❌ รับงานไม่สำเร็จ (${res.statusCode})")),
//           );
//         }
//       } else {
//         // ❌ ถ้าเกิน 20 เมตร
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "⚠️ คุณอยู่ห่างจากจุดรับ/ส่งมากเกินไป (${distanceToPickup.toStringAsFixed(1)} m)",
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       log("❌ acceptShipment error: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
//     }
//   }
// }
