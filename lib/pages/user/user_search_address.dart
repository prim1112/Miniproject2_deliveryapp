import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/internal_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SearchAddressPage extends StatefulWidget {
  final int userid;

  const SearchAddressPage({super.key, required this.userid});

  @override
  State<SearchAddressPage> createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  final MapController mapController = MapController();
  LatLng latlong = LatLng(16.246373, 103.251827);
  final TextEditingController _latlongController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<Map<String, String>> addresses = [];

  @override
  void initState() {
    super.initState();
    _latlongController.text = '${latlong.latitude}, ${latlong.longitude}';
    log("Received userid: ${widget.userid}");
  }

  @override
  void dispose() {
    _latlongController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แผนที่ GPS  ที่อยู่',
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
                    log('Tapped at: ${point.latitude}, ${point.longitude}');
                    setState(() {
                      latlong = point;
                      _latlongController.text =
                          '${point.latitude}, ${point.longitude}';
                    });
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
                        child: Icon(
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
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'พิกัด',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(
                    height: 80,
                    child: TextField(
                      controller: _latlongController,
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'ที่อยู่',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: 'พิมพ์ที่อยู่',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.add_box_rounded, color: Colors.red),
                        iconSize: 40,
                        onPressed: _addAddress,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ...addresses.map(
                    (addr) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '- ${addr["address"]} (${addr["gps"]})',
                        style: TextStyle(fontSize: 16),
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
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: Color(0xffCC0033),
                ),
                child: Text(
                  'เสร็จสิ้น',
                  style: TextStyle(
                    color: Color(0xFFFAFAFA),
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

  void _addAddress() async {
    final addressText = _addressController.text.trim();
    final gps = _latlongController.text.trim();

    if (addressText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("กรุณาพิมพ์ที่อยู่ก่อนเพิ่ม")));
      return;
    }

    final body = {
      "userid": widget.userid.toString(),
      "address_text": addressText,
      "gps": gps,
    };

    try {
      final response = await http.post(
        Uri.parse('$apiEndpoint/user/add-address'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        log("Address added successfully: $addressText");
        setState(() {
          addresses.add({"address": addressText, "gps": gps});
          _addressController.clear();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("เพิ่มที่อยู่เรียบร้อยแล้ว")));
      } else {
        log(
          "Failed to add address: $addressText, Response: ${response.statusCode} ${response.body}",
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("เพิ่มที่อยู่ไม่สำเร็จ")));
      }
    } catch (e) {
      log("Error adding address: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  void _saveAll() {
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("ยังไม่มีที่อยู่ที่เพิ่ม")));
      return;
    }
    log("All addresses saved: $addresses");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("บันทึกที่อยู่ทั้งหมดเรียบร้อยแล้ว")),
    );
  }
}
