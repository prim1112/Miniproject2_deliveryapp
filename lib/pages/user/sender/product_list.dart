import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/model/response/user_order_info_res.dart';
import 'package:dalivery_application/pages/user/sender/sender_order_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/config/shared/app_data.dart';

class ProductListPage extends StatefulWidget {
  final int receiverId;
  const ProductListPage({super.key, required this.receiverId});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool isLoading = true;
  Receiver? sender;
  Receiver? receiver;
  List<Address> senderAddresses = [];
  List<Address> receiverAddresses = [];
  int selectedSenderAddress = 0;
  int selectedReceiverAddress = 0;
  List<Map<String, dynamic>> products = [];
  String? createdShipmentId;
  final ImagePicker picker = ImagePicker();
  final TextEditingController detailCtl = TextEditingController();
  XFile? image;
  String url = "";

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);
      final int senderId = appData.userProfile.user_id;

      final res = await http.get(
        Uri.parse(
          "$url/user/orderInfo?senderId=$senderId&receiverId=${widget.receiverId}",
        ),
      );

      if (res.statusCode == 200) {
        final userOrderInfoRes = userOrderInfoResFromJson(res.body);
        setState(() {
          sender = userOrderInfoRes.sender;
          receiver = userOrderInfoRes.receiver;
          senderAddresses = sender!.addresses;
          receiverAddresses = receiver!.addresses;
          isLoading = false;
        });
      } else {
        log("❌ loadUserData Error: ${res.body}");
      }
    } catch (err) {
      log("❌ loadUserData Exception: $err");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มสินค้าและยืนยันที่อยู่'),
        backgroundColor: const Color(0xffCC0033),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sender != null) ...[
              const Text(
                "ข้อมูลผู้ส่ง (ฉัน)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text("ชื่อ: ${sender!.name}"),
              Text("เบอร์โทร: ${sender!.phone}"),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedSenderAddress,
                items: List.generate(
                  senderAddresses.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(senderAddresses[i].addressText),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => selectedSenderAddress = v ?? 0),
                decoration: const InputDecoration(
                  labelText: "เลือกที่อยู่ผู้ส่ง",
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (receiver != null) ...[
              const Text(
                "ข้อมูลผู้รับ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text("ชื่อ: ${receiver!.name}"),
              Text("เบอร์โทร: ${receiver!.phone}"),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedReceiverAddress,
                items: List.generate(
                  receiverAddresses.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(receiverAddresses[i].addressText),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => selectedReceiverAddress = v ?? 0),
                decoration: const InputDecoration(
                  labelText: "เลือกที่อยู่ผู้รับ",
                ),
              ),
            ],
            const SizedBox(height: 30),

            // ✅ ปุ่มเพิ่มสินค้า
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: addProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("เพิ่มสินค้า"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ แสดงรายการสินค้า
            if (products.isNotEmpty)
              Column(
                children: products.map((p) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: p['image'] != null
                          ? Image.file(
                              File(p['image']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.inventory_2, size: 40),
                      title: Text(p['details']),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 30),

            // ✅ ปุ่มถัดไป
            Center(
              child: FilledButton(
                onPressed: products.isEmpty ? null : submitShipment,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text("ถัดไป", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ เพิ่มสินค้าใหม่
  void addProductDialog() {
    detailCtl.clear();
    image = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มสินค้า"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: detailCtl,
              decoration: const InputDecoration(labelText: "รายละเอียดสินค้า"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) setState(() => image = picked);
              },
              child: const Text("เลือกรูป"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          FilledButton(
            onPressed: () {
              if (detailCtl.text.isEmpty) return;
              setState(() {
                products.add({"details": detailCtl.text, "image": image?.path});
              });
              Navigator.pop(context);
            },
            child: const Text("บันทึกสินค้า"),
          ),
        ],
      ),
    );
  }

  Future<void> submitShipment() async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);
      final int senderId = appData.userProfile.user_id;

      final pickup = senderAddresses[selectedSenderAddress];
      final delivery = receiverAddresses[selectedReceiverAddress];

      final res = await http.post(
        Uri.parse("$url/deliveryRoutes/shipment/create"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": widget.receiverId,
          "pickup_address_id": pickup.addressId,
          "delivery_address_id": delivery.addressId,
        }),
      );

      if (res.statusCode != 201) {
        log("❌ Create shipment error: ${res.body}");
        return;
      }

      final shipment = jsonDecode(res.body)['shipment'];
      final shipmentId = shipment['shipment_id'];
      createdShipmentId = shipmentId.toString();

      appData.setCreatedShipmentId(shipmentId);

      for (final p in products) {
        var req = http.MultipartRequest(
          "POST",
          Uri.parse("$url/deliveryRoutes/product"),
        );
        req.fields['shipment_id'] = shipmentId.toString();
        req.fields['details'] = p['details'];
        if (p['image'] != null) {
          req.files.add(await http.MultipartFile.fromPath("file", p['image']));
        }
        await req.send();
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SenderOrderSummaryPage()),
      );
    } catch (err) {
      log("❌ submitShipment error: $err");
    }
  }
}
