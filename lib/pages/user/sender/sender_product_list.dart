import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/model/response/user_order_info_res.dart';
import 'package:dalivery_application/pages/user/sender/sender_homepage.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มสินค้าและยืนยันที่อยู่',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffCC0033),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SenderPage()),
            );
          },
        ),
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
                    child: Text(senderAddresses[i].addressText, maxLines: 3),
                  ),
                ),
                selectedItemBuilder: (context) {
                  return senderAddresses.map((address) {
                    return Text(
                      address.addressText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }).toList();
                },
                onChanged: (v) =>
                    setState(() => selectedSenderAddress = v ?? 0),
                decoration: const InputDecoration(
                  labelText: "เลือกที่อยู่ผู้ส่ง",
                ),
                isExpanded: true,
              ),
            ],
            const SizedBox(height: 20),
            if (receiver != null) ...[
              const Text(
                "ข้อมูลผู้รับ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // ✅ แสดงรูปผู้รับ
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: receiver!.imageUser.isNotEmpty
                      ? NetworkImage(receiver!.imageUser)
                      : const AssetImage("assets/images/unnamed.webp")
                            as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),

              // ✅ ข้อมูลผู้รับ
              Text("ชื่อ: ${receiver!.name}"),
              Text("เบอร์โทร: ${receiver!.phone}"),
              const SizedBox(height: 8),

              // ✅ Dropdown เลือกที่อยู่ผู้รับ
              DropdownButtonFormField<int>(
                value: selectedReceiverAddress,
                items: List.generate(
                  receiverAddresses.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(
                      receiverAddresses[i].addressText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => selectedReceiverAddress = v ?? 0),
                decoration: const InputDecoration(
                  labelText: "เลือกที่อยู่ผู้รับ",
                ),
                isExpanded: true,
              ),
              const SizedBox(height: 10),

              // ✅ แสดงพิกัดจากที่อยู่ที่เลือกไว้
              if (receiverAddresses.isNotEmpty)
                Text(
                  "📍 พิกัด: "
                  "ละติจูด ${receiverAddresses[selectedReceiverAddress].latitude.toStringAsFixed(6)}, "
                  "ลองจิจูด ${receiverAddresses[selectedReceiverAddress].longitude.toStringAsFixed(6)}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
            ],

            const SizedBox(height: 20),
            Center(
              child: FilledButton.icon(
                onPressed: addProductDialog,
                label: const Text(" + เพิ่มสินค้า "),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFCC0033),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
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
            Center(
              child: FilledButton(
                onPressed: products.isEmpty ? null : submitShipment,
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xff0A9718),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
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

  void addProductDialog() {
    detailCtl.clear();
    image = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF0F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) setStateDialog(() => image = picked);
                  },
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(image!.path),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black54, width: 2),
                          ),
                          child: const Icon(Icons.image_outlined, size: 80),
                        ),
                ),
                const SizedBox(height: 10),

                FilledButton(
                  onPressed: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) setStateDialog(() => image = picked);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0033),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text("เพิ่มรูปภาพ"),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "รายละเอียด",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: detailCtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (detailCtl.text.isEmpty) return;
                    setState(() {
                      products.add({
                        "details": detailCtl.text,
                        "image": image?.path,
                      });
                    });
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("ตกลง", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
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
