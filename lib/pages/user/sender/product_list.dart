import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/user_model_get_res.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:dalivery_application/pages/user/sender/sender_order_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProductListPage extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String shipmentId;
  final String? suserName;

  const ProductListPage({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.shipmentId,
    this.suserName,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  int selectedIndex = 0;

  String apiEndpoint = "";
  UserModel? sender;
  UserModel? receiver;
  bool isLoading = true;

  final TextEditingController detailController = TextEditingController();

  int selectedSenderAddressIndex = 0;
  int selectedReceiverAddressIndex = 0;

  String? createdShipmentId;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      log("API ENDPOINT: ${value['apiEndpoint']}");
      setState(() {
        apiEndpoint = value['apiEndpoint'];
      });
      _fetchOrderInfo();
    });
  }

  Future<void> _fetchOrderInfo() async {
    if (apiEndpoint.isEmpty) return;
    try {
      final url = Uri.parse(
        "$apiEndpoint/user/orderInfo?senderId=${widget.senderId}&receiverId=${widget.receiverId}",
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          sender = UserModel.fromJson(data['sender']);
          receiver = UserModel.fromJson(data['receiver']);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      log("Error _fetchOrderInfo: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _createShipment() async {
    if (sender == null || receiver == null) return;

    final pickupAddr = sender!.addresses[selectedSenderAddressIndex];
    final deliveryAddr = receiver!.addresses[selectedReceiverAddressIndex];

    final url = Uri.parse("$apiEndpoint/shipments/shipments");
    final body = {
      "sender_id": widget.senderId,
      "receiver_id": widget.receiverId,
      "pickup_address_id": pickupAddr.addressId,
      "delivery_address_id": deliveryAddr.addressId,
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        setState(() {
          createdShipmentId = data['shipment']['shipment_id'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สร้าง Shipment สำเร็จ: $createdShipmentId")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สร้าง Shipment ล้มเหลว: ${res.body}")),
        );
      }
    } catch (e) {
      log("Error _createShipment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffCC0033),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'เพิ่มสินค้า',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sender != null) ...[
                    Text(
                      'Sender : ${sender!.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Phone : ${sender!.phone}'),
                    if (sender!.addresses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text("เลือกที่อยู่ผู้ส่ง:"),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: selectedSenderAddressIndex,
                        items: List.generate(
                          sender!.addresses.length,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              sender!.addresses[index].addressText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedSenderAddressIndex = value ?? 0;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  if (receiver != null) ...[
                    Text(
                      'Receiver : ${receiver!.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text('Phone : ${receiver!.phone}'),
                    if (receiver!.addresses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text("เลือกที่อยู่ผู้รับ:"),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value: selectedReceiverAddressIndex,
                        items: List.generate(
                          receiver!.addresses.length,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              receiver!.addresses[index].addressText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedReceiverAddressIndex = value ?? 0;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          createdShipmentId != null ? null : _createShipment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("ยืนยันที่อยู่"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: image != null
                                            ? Image.file(
                                                File(image!.path),
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/images.png',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final XFile? picked =
                                            await picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            image = picked;
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffCC0033),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("เพิ่มรูปภาพ"),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: detailController,
                                      decoration: const InputDecoration(
                                        labelText: "รายละเอียด",
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (createdShipmentId == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "กรุณายืนยันที่อยู่ก่อน"),
                                            ),
                                          );
                                          return;
                                        }

                                        final url = Uri.parse(
                                            "$apiEndpoint/products/products");
                                        var request =
                                            http.MultipartRequest("POST", url);
                                        request.fields['shipment_id'] =
                                            createdShipmentId ?? "";
                                        request.fields['details'] =
                                            detailController.text;

                                        if (image != null) {
                                          request.files.add(
                                            await http.MultipartFile.fromPath(
                                              "file",
                                              image!.path,
                                            ),
                                          );
                                        }

                                        final streamedRes = await request.send();
                                        final res = await http.Response
                                            .fromStream(streamedRes);

                                        if (res.statusCode == 201) {
                                          final data = json.decode(res.body);
                                          setState(() {
                                            products.add(data['product']);
                                          });
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text(res.body)),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("บันทึกสินค้า"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("เพิ่มรายการ"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (products.isNotEmpty) ...[
                    const Text(
                      "สินค้าในรายการ:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: products.map((p) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 55, vertical: 8),
                          child: Row(
                            children: [
                              p['image_product'] != null
                                  ? Image.network(
                                      p['image_product'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/images.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p['details'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (createdShipmentId == null || products.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("กรุณาเลือกที่อยู่และเพิ่มสินค้า"),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SenderOrderSummaryPage(
                              shipmentId: createdShipmentId!,
                              sender: sender!,
                              receiver: receiver!,
                              products: products,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("ถัดไป"),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}
