// import 'dart:convert';
// import 'dart:developer';
// import 'package:dalivery_application/config/config.dart';
// import 'package:dalivery_application/config/internal_config.dart';
// import 'package:dalivery_application/pages/login.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class SearchAddressPage extends StatefulWidget {
//   final int userid;
//   final String name;
//   SearchAddressPage({super.key, required this.userid, required this.name});

//   @override
//   State<SearchAddressPage> createState() => _SearchAddressPageState();
// }

// class _SearchAddressPageState extends State<SearchAddressPage> {
//   final MapController mapController = MapController();
//   LatLng latlong = LatLng(16.246373, 103.251827);
//   final TextEditingController _latController = TextEditingController();
//   final TextEditingController _longController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   List<Map<String, String>> addresses = [];
//   String url = '';

//   @override
//   void initState() {
//     super.initState();
//     Configuration.getConfig()
//         .then((value) {
//           url = value['apiEndpoint'];
//           log(value['apiEndpoint']);
//         })
//         .catchError((err) {
//           log(err.toString());
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'แผนที่ GPS  ที่อยู่',
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xffCC0033),
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.6,
//               child: FlutterMap(
//                 mapController: mapController,
//                 options: MapOptions(
//                   initialCenter: latlong,
//                   initialZoom: 15.2,
//                   onTap: (tapPosition, point) {
//                     log('Tapped at: ${point.latitude}, ${point.longitude}');
//                     setState(() {
//                       latlong = point;
//                       _latController.text = point.latitude.toString();
//                       _longController.text = point.longitude.toString();
//                     });
//                   },
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=822b483170524fb6b9615850ba72ce54',
//                     userAgentPackageName: 'net.gonggang.osm_demo',
//                   ),
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: latlong,
//                         child: Icon(
//                           Icons.location_on,
//                           color: Colors.red,
//                           size: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 30),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'พิกัด',
//                     style: TextStyle(color: Colors.black, fontSize: 18),
//                   ),
//                   SizedBox(
//                     height: 80,
//                     child: TextField(
//                       controller: _latController,
//                       readOnly: true,
//                       decoration: InputDecoration(
//                         labelText: "Latitude",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     controller: _longController,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       labelText: "Longitude",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   Text(
//                     'ที่อยู่',
//                     style: TextStyle(color: Colors.black, fontSize: 18),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _addressController,
//                           decoration: InputDecoration(
//                             hintText: 'พิมพ์ที่อยู่',
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 10,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(40),
//                               borderSide: BorderSide(color: Colors.red),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(40),
//                               borderSide: BorderSide(color: Colors.red),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       IconButton(
//                         icon: Icon(Icons.add_box_rounded, color: Colors.red),
//                         iconSize: 40,
//                         onPressed: _addAddress,
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   ...addresses.map(
//                     (addr) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Text(
//                         '- ${addr["address"]} (${addr["gps"]})',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 30, bottom: 30),
//               child: ElevatedButton(
//                 onPressed: _saveAll,
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: const Color.fromARGB(255, 0, 0, 0),
//                   backgroundColor: Color(0xffCC0033),
//                 ),
//                 child: Text(
//                   'เสร็จสิ้น',
//                   style: TextStyle(
//                     color: Color(0xFFFAFAFA),
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _addAddress() async {
//     final addressText = _addressController.text.trim();
//     final lat = _latController.text.trim();
//     final long = _longController.text.trim();

//     if (addressText.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("กรุณาพิมพ์ที่อยู่ก่อนเพิ่ม")));
//       return;
//     }

//     final body = {
//       "userid": widget.userid.toString(),
//       "address_text": addressText,
//       "latitude": lat,
//       "longitude": long,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse('$url/user/add-address'),
//         headers: {"Content-Type": "application/json; charset=utf-8"},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 201) {
//         log("✅ Address added successfully: $addressText");
//         setState(() {
//           addresses.add({"address": addressText, "gps": "$lat, $long"});
//           _addressController.clear();
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("เพิ่มที่อยู่เรียบร้อยแล้ว")));
//       } else {
//         log("❌ Failed to add address: ${response.statusCode} ${response.body}");
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("เพิ่มที่อยู่ไม่สำเร็จ")));
//       }
//     } catch (e) {
//       log("⚠️ Error adding address: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
//     }
//   }

//   void _saveAll() {
//     if (addresses.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("ยังไม่มีที่อยู่ที่เพิ่ม")));
//       return;
//     }

//     log("All addresses saved: $addresses");

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("บันทึกเรียบร้อย"),
//           content: Text("บันทึกที่อยู่ทั้งหมดเรียบร้อยแล้ว"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // ปิด dialog
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LoginPage(),
//                   ), // ใส่ชื่อผู้ใช้ถ้ามี
//                 );
//               },
//               child: Text("เสร็จสิ้น"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/internal_config.dart';
import 'package:dalivery_application/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SearchAddressPage extends StatefulWidget {
  final int userid;
  final String name;

  const SearchAddressPage({
    super.key,
    required this.userid,
    required this.name,
  });

  @override
  State<SearchAddressPage> createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  final MapController mapController = MapController();
  LatLng latlong = LatLng(16.246373, 103.251827);

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, String>> addresses = [];
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig()
        .then((value) {
          url = value['apiEndpoint'];
          log(value['apiEndpoint']);
        })
        .catchError((err) {
          log(err.toString());
        });
  }

  /// ✅ reverse geocode ดึงชื่อที่อยู่จาก lat,long
  Future<void> _getAddressFromLatLong(LatLng point) async {
    try {
      final apiUrl =
          "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}";

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "User-Agent": "DaliveryApp/1.0 (contact: 65011212063@msu.ac.th)",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'] ?? "ไม่พบที่อยู่";

        setState(() {
          _addressController.text = displayName;
          _latController.text = point.latitude.toStringAsFixed(6);
          _longController.text = point.longitude.toStringAsFixed(6);
        });
      } else {
        log("❌ reverse geocode failed: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "เรียก API ที่อยู่ไม่สำเร็จ (${response.statusCode})",
            ),
          ),
        );
      }
    } catch (e) {
      log("⚠️ Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แผนที่ GPS ที่อยู่',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffCC0033),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: latlong,
                  initialZoom: 15.2,
                  onTap: (tapPosition, point) {
                    log('📍 Tapped at: ${point.latitude}, ${point.longitude}');
                    setState(() => latlong = point);
                    _getAddressFromLatLong(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=822b483170524fb6b9615850ba72ce54',
                    userAgentPackageName: 'net.gonggang.osm_demo',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latlong,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('พิกัด', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _latController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Latitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _longController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Longitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'ที่อยู่ (อัตโนมัติจากแผนที่)',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _addressController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'แตะบนแผนที่เพื่อเลือกที่อยู่',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "แตะ + เพื่อเพิ่มที่อยู่นี้ลงในรายการ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_box_rounded,
                          color: Colors.red,
                        ),
                        iconSize: 40,
                        onPressed: _addAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...addresses.map(
                    (addr) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '• ${addr["address"]}\n   (${addr["gps"]})',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffCC0033),
                ),
                child: const Text(
                  'เสร็จสิ้น',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ เพิ่มที่อยู่ลง Firebase
  void _addAddress() async {
    final addressText = _addressController.text.trim();
    final lat = _latController.text.trim();
    final long = _longController.text.trim();

    if (addressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาแตะบนแผนที่เพื่อเลือกที่อยู่ก่อน")),
      );
      return;
    }

    final body = {
      "userid": widget.userid.toString(),
      "address_text": addressText,
      "latitude": lat,
      "longitude": long,
    };

    try {
      final response = await http.post(
        Uri.parse('$url/user/add-address'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        log("✅ Address added successfully: $addressText");
        setState(() {
          addresses.add({"address": addressText, "gps": "$lat, $long"});
          _addressController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เพิ่มที่อยู่เรียบร้อยแล้ว")),
        );
      } else {
        log("❌ Failed to add address: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("เพิ่มที่อยู่ไม่สำเร็จ")));
      }
    } catch (e) {
      log("⚠️ Error adding address: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  void _saveAll() {
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ยังไม่มีที่อยู่ที่เพิ่ม")));
      return;
    }

    log("All addresses saved: $addresses");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("บันทึกเรียบร้อย"),
          content: const Text("บันทึกที่อยู่ทั้งหมดเรียบร้อยแล้ว"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text("เสร็จสิ้น"),
            ),
          ],
        );
      },
    );
  }
}
