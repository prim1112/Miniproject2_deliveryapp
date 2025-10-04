import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/user_search_get_res.dart';
import 'package:dalivery_application/pages/user/sender/product_list.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SenderPage extends StatefulWidget {
  final String name;
  final String userid;
  final int senderid; // 🆕 userid ของผู้ส่ง
  final int receiverid;

  const SenderPage({
    super.key,
    required this.name,
    required this.userid,
    required this.senderid,
    required this.receiverid,
  });

  @override
  State<SenderPage> createState() => _SenderPageState();
}

class _SenderPageState extends State<SenderPage> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? apiEndpoint;
  List<UserSearchGetResponse> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // โหลด config ครั้งเดียว
    Configuration.getConfig().then((value) {
      log("API ENDPOINT: ${value['apiEndpoint']}");
      setState(() {
        apiEndpoint = value['apiEndpoint'];
      });
      _fetchUsers(""); // โหลด users ครั้งแรก
    });
  }

  void goToAddOrder(int senderid, int receiverid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductListPage(senderid: senderid, receiverid: receiverid),
      ),
    );
  }

  /// ฟังก์ชันเรียก API backend
  Future<void> _fetchUsers(String query) async {
    if (apiEndpoint == null) return; // รอ config มาก่อน

    try {
      final url = Uri.parse(
        '$apiEndpoint/user/userPhone?userID=${widget.userid}&phone=$query',
      );
      log("CALL API: $url");

      setState(() => isLoading = true);

      final response = await http.get(url);

      log("STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data["users"] ?? [];
        setState(() {
          users = usersJson
              .map((u) => UserSearchGetResponse.fromJson(u))
              .toList();
        });
      } else {
        setState(() => users = []);
        log("Error: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFCC0033),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'หน้าหลักคนส่ง',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                _fetchUsers(value);
              },
              decoration: InputDecoration(
                hintText: "ค้นหาจากเบอร์",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC0033),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC0033),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                  ? const Center(child: Text("ไม่พบผู้ใช้"))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: 120,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundImage: user.imageUser != null
                                      ? NetworkImage(user.imageUser!)
                                      : const AssetImage(
                                              "assets/images/unnamed.webp",
                                            )
                                            as ImageProvider,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name.isNotEmpty
                                            ? user.name
                                            : "ไม่ทราบชื่อ",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user.phone,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    goToAddOrder(widget.senderid, user.userId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCC0033),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "รับรายการ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
