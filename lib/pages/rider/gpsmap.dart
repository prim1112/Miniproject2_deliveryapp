// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:dalivery_application/config/config.dart';
// import 'package:dalivery_application/model/response/shipment_detail_res.dart';
// import 'package:dalivery_application/pages/rider/rider_homepage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';

// class GPSandMapPage extends StatefulWidget {
//   final int orderId;

//   const GPSandMapPage({Key? key, required this.orderId}) : super(key: key);

//   @override
//   State<GPSandMapPage> createState() => _GPSandMapPageState();
// }

// class _GPSandMapPageState extends State<GPSandMapPage> {
//   String url = '';
//   File? _image;
//   File? _image2;
//   ShipmentFullDetailRes? shipment;

//   LatLng? riderPosition;
//   LatLng? customerPosition;
//   final MapController mapController = MapController();
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     Configuration.getConfig().then((value) {
//       url = value['apiEndpoint'];
//       log("🌐 URL Loaded: $url");
//       _fetchShipmentDetail();
//       _initLocationTracking(); // ✅ เริ่มติดตามตำแหน่งแบบ Real-time
//     });
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xffCC0033),
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'ติดตามการจัดส่ง',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // ✅ แผนที่แสดงตำแหน่งไรเดอร์ + ลูกค้า
//                 Expanded(
//                   child: FlutterMap(
//                     mapController: mapController,
//                     options: MapOptions(
//                       initialCenter: riderPosition ?? LatLng(13.75, 100.52),
//                       initialZoom: 15,
//                     ),

//                     children: [
//                       TileLayer(
//                         urlTemplate:
//                             'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                         userAgentPackageName: 'dalivery_application',
//                       ),
//                       MarkerLayer(
//                         markers: [
//                           if (riderPosition != null)
//                             Marker(
//                               point: riderPosition!,
//                               child: const Icon(
//                                 Icons.delivery_dining,
//                                 color: Colors.blue,
//                                 size: 45,
//                               ),
//                             ),
//                           if (customerPosition != null)
//                             Marker(
//                               point: customerPosition!,
//                               child: const Icon(
//                                 Icons.location_pin,
//                                 color: Colors.red,
//                                 size: 45,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 _buildImagePicker(
//                   file: _image,
//                   onPick: _pickImage,
//                   onSave: () {
//                     if (_image != null) _uploadImage(_image!, 3);
//                   },
//                 ),
//                 _buildImagePicker(
//                   file: _image2,
//                   onPick: _pickImage2,
//                   onSave: () {
//                     if (_image2 != null) _uploadImage(_image2!, 4);
//                   },
//                 ),

//                 const SizedBox(height: 10),
//                 _buildSuccessButton(),
//                 const SizedBox(height: 20),
//               ],
//             ),
//     );
//   }

//   Widget _buildImagePicker({
//     required File? file,
//     required Function() onPick,
//     required Function() onSave,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'เพิ่มรูปภาพ ประกอบสถานะ:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: onPick,
//                   child: Container(
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: file != null
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.file(
//                               file,
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                             ),
//                           )
//                         : const Center(
//                             child: Icon(
//                               Icons.add,
//                               size: 40,
//                               color: Colors.black54,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               ElevatedButton(
//                 onPressed: onSave,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[300],
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 14,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   'บันทึก',
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuccessButton() {
//     return Center(
//       child: ElevatedButton(
//         onPressed: _completeShipment,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xff0B6623),
//           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//         ),
//         child: const Text(
//           'ส่งของสำเร็จ',
//           style: TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Future<void> _fetchShipmentDetail() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}'),
//       );
//       if (response.statusCode == 200) {
//         final data = shipmentFullDetailResFromJson(response.body);
//         setState(() {
//           shipment = data;
//           customerPosition = LatLng(
//             double.tryParse(data.pickupAddress.latitude.toString()) ?? 13.75,
//             double.tryParse(data.pickupAddress.longitude.toString()) ?? 100.52,
//           );
//           isLoading = false;
//         });
//       } else {
//         log('⚠️ โหลด shipment ล้มเหลว: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('❌ fetchShipmentDetail error: $e');
//     }
//   }

//   Future<void> _initLocationTracking() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('กรุณาเปิด GPS')));
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }

//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.best,
//         distanceFilter: 5,
//       ),
//     ).listen((Position position) {
//       final newPos = LatLng(position.latitude, position.longitude);
//       setState(() => riderPosition = newPos);
//       mapController.move(newPos, mapController.camera.zoom);
//       _updateRiderLocation(newPos);
//     });
//   }

//   Future<void> _updateRiderLocation(LatLng pos) async {
//     try {
//       final res = await http.put(
//         Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}/location'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'rider_latitude': pos.latitude,
//           'rider_longitude': pos.longitude,
//         }),
//       );
//       if (res.statusCode == 200) {
//         log("📡 อัปเดตพิกัด -> ${pos.latitude}, ${pos.longitude}");
//       } else {
//         log("⚠️ update location failed: ${res.statusCode}");
//       }
//     } catch (e) {
//       log('❌ update location error: $e');
//     }
//   }

//   Future<void> _uploadImage(File file, int status) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$url/deliveryRoutes/shipment_photos/upload'),
//       );
//       request.fields['shipment_id'] = widget.orderId.toString();
//       request.fields['status'] = status.toString();
//       request.files.add(await http.MultipartFile.fromPath('file', file.path));

//       var response = await request.send();
//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('อัปโหลดรูปสถานะ $status สำเร็จ ✅')),
//         );
//       } else {
//         log('⚠️ upload image failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('❌ upload image error: $e');
//     }
//   }

//   Future<void> _completeShipment() async {
//     try {
//       final res = await http.put(
//         Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}/complete'),
//       );
//       if (res.statusCode == 200) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('ส่งของสำเร็จ ✅')));
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const RiderHomepage()),
//         );
//       } else {
//         log('⚠️ completeShipment failed: ${res.statusCode}');
//       }
//     } catch (e) {
//       log('❌ completeShipment error: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (picked != null) {
//       setState(() => _image = File(picked.path));
//     }
//   }

//   Future<void> _pickImage2() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera);
//     if (picked != null) {
//       setState(() => _image2 = File(picked.path));
//     }
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/shipment_detail_res.dart';
import 'package:dalivery_application/pages/rider/rider_homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class GPSandMapPage extends StatefulWidget {
  final int orderId;

  const GPSandMapPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<GPSandMapPage> createState() => _GPSandMapPageState();
}

class _GPSandMapPageState extends State<GPSandMapPage> {
  String url = '';
  File? _image1;
  File? _image2;
  ShipmentFullDetailRes? shipment;

  LatLng riderPosition = const LatLng(13.75, 100.52);
  LatLng customerPosition = const LatLng(13.72, 100.50);
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      log("🌐 API: $url");
      _fetchShipmentDetail();
      _initLocationTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        automaticallyImplyLeading: false,
        title: const Text(
          'ติดตามการจัดส่ง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: riderPosition,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dalivery_application',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: riderPosition,
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.blue,
                          size: 45,
                        ),
                      ),
                      Marker(
                        point: customerPosition,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildImageBox(
              title: "เพิ่มรูปภาพสถานะ (กำลังไปส่งสินค้า)",
              file: _image1,
              onPick: _pickImage1,
              onSave: () {
                if (_image1 != null) _uploadImage(_image1!, 3);
              },
            ),

            _buildImageBox(
              title: "เพิ่มรูปภาพสถานะ (ส่งของสำเร็จ)",
              file: _image2,
              onPick: _pickImage2,
              onSave: () {
                if (_image2 != null) _uploadImage(_image2!, 4);
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _completeShipment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0B6623),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'ส่งของสำเร็จ',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox({
    required String title,
    required File? file,
    required VoidCallback onPick,
    required VoidCallback onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPick,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: file != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              file,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.black54,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetchShipmentDetail() async {
    try {
      final res = await http.get(
        Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}'),
      );
      if (res.statusCode == 200) {
        final data = shipmentFullDetailResFromJson(res.body);
        setState(() {
          shipment = data;
          customerPosition = LatLng(
            double.tryParse(data.deliveryAddress.latitude.toString()) ?? 13.72,
            double.tryParse(data.deliveryAddress.longitude.toString()) ??
                100.50,
          );
        });
      } else {
        log("⚠️ โหลด shipment ไม่สำเร็จ: ${res.statusCode}");
      }
    } catch (e) {
      log("❌ fetchShipmentDetail error: $e");
    }
  }

  Future<void> _initLocationTracking() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      setState(() => riderPosition = LatLng(pos.latitude, pos.longitude));
      mapController.move(riderPosition, mapController.camera.zoom);
      _updateRiderLocation(riderPosition);
    });
  }

  Future<void> _updateRiderLocation(LatLng pos) async {
    try {
      final res = await http.put(
        Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rider_latitude': pos.latitude,
          'rider_longitude': pos.longitude,
        }),
      );
      if (res.statusCode == 200) {
        log("📡 อัปเดตพิกัด -> ${pos.latitude}, ${pos.longitude}");
      }
    } catch (e) {
      log("❌ update location error: $e");
    }
  }

  Future<void> _uploadImage(File file, int status) async {
    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$url/deliveryRoutes/shipments/${widget.orderId}/status$status',
        ),
      );
      req.files.add(await http.MultipartFile.fromPath('file', file.path));

      var res = await req.send();
      if (res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัปโหลดรูปสถานะ $status สำเร็จ ✅')),
        );
      } else {
        log('⚠️ upload image failed: ${res.statusCode}');
      }
    } catch (e) {
      log('❌ upload image error: $e');
    }
  }

  Future<void> _completeShipment() async {
    try {
      final res = await http.put(
        Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}/complete'),
      );
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ส่งของสำเร็จ ✅')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RiderHomepage()),
        );
      }
    } catch (e) {
      log("❌ completeShipment error: $e");
    }
  }

  Future<void> _pickImage1() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _image1 = File(picked.path));
  }

  Future<void> _pickImage2() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _image2 = File(picked.path));
  }
}
