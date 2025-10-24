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

        if (status == 3) {
          mapController.move(customerPosition, 16);
        }
      } else {
        log('⚠️ upload image failed: ${res.statusCode}');
      }
    } catch (e) {
      log('❌ upload image error: $e');
    }
  }

  Future<void> _completeShipment() async {
    // แสดง SnackBar หรือ Dialog ก่อนกลับก็ได้
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('ส่งของสำเร็จ ✅')));

    // รอให้เห็นข้อความเล็กน้อย
    await Future.delayed(const Duration(milliseconds: 800));

    // ✅ กลับไปหน้า RiderHomepage แล้วล้าง Stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RiderHomepage()),
      (route) => false,
    );
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
