import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/shipment_detail_res.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ReceiverOrderTrackingPage extends StatefulWidget {
  final int orderId;

  const ReceiverOrderTrackingPage({Key? key, required this.orderId})
    : super(key: key);

  @override
  State<ReceiverOrderTrackingPage> createState() =>
      _ReceiverOrderTrackingPageState();
}

class _ReceiverOrderTrackingPageState extends State<ReceiverOrderTrackingPage> {
  String url = '';
  ShipmentFullDetailRes? shipment;
  LatLng? riderPosition;
  LatLng? customerPosition;
  final MapController mapController = MapController();
  bool isLoading = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      _fetchShipmentDetail();
      _startRiderTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'ติดตามการจัดส่ง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  //แผนที่
                  SizedBox(
                    height: 400,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter:
                            customerPosition ?? LatLng(13.75, 100.52),
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'dalivery_application',
                        ),
                        MarkerLayer(
                          markers: [
                            if (riderPosition != null)
                              Marker(
                                point: riderPosition!,
                                child: const Icon(
                                  Icons.delivery_dining,
                                  color: Colors.blue,
                                  size: 45,
                                ),
                              ),
                            if (customerPosition != null)
                              Marker(
                                point: customerPosition!,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTimelineItem(
                          "รอไรเดอร์มารับสินค้า",
                          _getPhotoUrlForStatus(1),
                        ),
                        _buildTimelineItem(
                          "ไรเดอร์รับงาน",
                          _getPhotoUrlForStatus(2),
                        ),
                        _buildTimelineItem(
                          "ไรเดอร์รับสินค้าแล้วและกำลังเดินทาง",
                          _getPhotoUrlForStatus(3),
                        ),
                        _buildTimelineItem(
                          "ไรเดอร์นำส่งสินค้าแล้ว",
                          _getPhotoUrlForStatus(4),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ ดึงรูปตามสถานะจาก shipment_photos
  String? _getPhotoUrlForStatus(int status) {
    try {
      return shipment!.shipmentPhotos
          .firstWhere((p) => p.status == status)
          .photoUrl;
    } catch (e) {
      return null;
    }
  }

  Widget _buildTimelineItem(
    String text,
    String? imageUrl, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.black),
            ),
            if (!isLast)
              Container(width: 2, height: 70, color: Colors.grey.shade400),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                if (imageUrl != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchShipmentDetail() async {
    try {
      final response = await http.get(
        Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}'),
      );
      if (response.statusCode == 200) {
        final data = shipmentFullDetailResFromJson(response.body);
        setState(() {
          shipment = data;
          customerPosition = LatLng(
            double.tryParse(data.deliveryAddress.latitude.toString()) ?? 13.75,
            double.tryParse(data.deliveryAddress.longitude.toString()) ??
                100.52,
          );
          isLoading = false;
        });
      } else {
        log('⚠️ โหลด shipment ล้มเหลว: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ fetchShipmentDetail error: $e');
    }
  }

  // ✅ Receiver จะไม่อัปเดต GPS ตัวเอง แต่จะฟังพิกัดของไรเดอร์จาก backend
  void _startRiderTracking() async {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final res = await http.get(
          Uri.parse('$url/deliveryRoutes/shipments/${widget.orderId}'),
        );

        if (res.statusCode == 200) {
          final data = shipmentFullDetailResFromJson(res.body);

          final lat = double.tryParse(data.riderLatitude.toString());
          final lng = double.tryParse(data.riderLongitude.toString());

          if (lat != null && lng != null) {
            setState(() {
              riderPosition = LatLng(lat, lng);
              shipment = data; // ✅ อัปเดต shipment ทุกครั้ง
            });

            // ขยับแผนที่ให้อยู่ตรงตำแหน่งใหม่
            mapController.move(LatLng(lat, lng), mapController.camera.zoom);
          }
        }
      } catch (e) {
        log('⚠️ rider tracking error: $e');
      }
      return mounted;
    });
  }
}
