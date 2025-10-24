import 'package:dalivery_application/model/response/user_model_get_res.dart';
import 'package:dalivery_application/pages/user/sender/receiver_order_tracking_page.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';

class RecStatusDetailsPage extends StatefulWidget {
  final String shipmentId;
  final UserModel sender;
  final UserModel receiver;
  final List<Map<String, dynamic>> products;
  final int status; // ✅ เก็บสถานะ
  final String? photoUrl; // ✅ เพิ่มตัวแปรเก็บรูปจากหน้า SenderOrderSummaryPage

  const RecStatusDetailsPage({
    super.key,
    required this.shipmentId,
    required this.sender,
    required this.receiver,
    required this.products,
    required this.status,
    this.photoUrl, // ✅ optional
  });

  @override
  State<RecStatusDetailsPage> createState() => _RecStatusDetailsPageState();
}

class _RecStatusDetailsPageState extends State<RecStatusDetailsPage> {
  int selectedIndex = 0;

  // ✅ ฟังก์ชันแปลงตัวเลขเป็นข้อความ
  String getStatusText(int status) {
    switch (status) {
      case 1:
        return "รอไรเดอร์มารับสินค้า";
      case 2:
        return "ไรเดอร์รับงาน (กำลังเดินทางมารับสินค้า)";
      case 3:
        return "ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง";
      case 4:
        return "ไรเดอร์นำส่งสินค้าแล้ว";
      default:
        return "ไม่ทราบสถานะ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffCC0033),
        title: const Text(
          'สถานะคนรับ',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Shipment ID : ${widget.shipmentId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: widget.photoUrl != null
                          ? Image.network(
                              widget.photoUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/don.webp',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.sender.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "Phone : ${widget.sender.phone}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "Order : ${widget.products.map((p) => p['details']).join(", ")}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            "Address : ${widget.receiver.addresses.isNotEmpty ? widget.receiver.addresses.first.addressText : "-"}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text(
                                "สถานะ : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                getStatusText(widget.status),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReceiverOrderTrackingPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "รายละเอียด",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
