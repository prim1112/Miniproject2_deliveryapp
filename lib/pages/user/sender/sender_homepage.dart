import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/user_search_get_res.dart';
import 'package:dalivery_application/pages/user/sender/sender_product_list.dart';
import 'package:dalivery_application/pages/user/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dalivery_application/config/shared/app_data.dart';

class SenderPage extends StatefulWidget {
  const SenderPage({super.key});

  @override
  State<SenderPage> createState() => _SenderPageState();
}

class _SenderPageState extends State<SenderPage> {
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<UserSearchGetResponse> users = [];
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((value) {
      url = value['apiEndpoint'];
      final appData = Provider.of<AppData>(context, listen: false);
      final senderId = appData.userProfile.user_id;
      _fetchUsers("", senderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final senderId = appData.userProfile.user_id;
    final userName = appData.userProfile.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFCC0033),
        title: Text(
          'หน้าหลักคนส่ง  ($userName)',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => _fetchUsers(value, senderId),
              decoration: InputDecoration(
                hintText: "ค้นหาจากเบอร์โทรศัพท์",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC0033),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC0033),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Column(
              children: users.map((user) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: user.image_user != null
                          ? NetworkImage(user.image_user!)
                          : const AssetImage("assets/images/unnamed.webp")
                                as ImageProvider,
                    ),
                    title: Text(
                      user.name.isNotEmpty ? user.name : "ไม่ทราบชื่อ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(user.phone),
                    trailing: ElevatedButton(
                      onPressed: () {
                        goToAddOrder(user.user_id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC0033),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "รับรายการ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: MainBottomNav(
        selectedIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
      ),
    );
  }

  void goToAddOrder(int receiverId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(receiverId: receiverId),
      ),
    );
  }

  Future<void> _fetchUsers(String query, int senderId) async {
    if (url.isEmpty) return;
    try {
      final apiUrl = Uri.parse(
        '$url/user/users/search?userID=$senderId&phone=$query',
      );
      log("CALL API: $apiUrl");

      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usersJson = data["users"] as List<dynamic>?;

        setState(() {
          users =
              usersJson
                  ?.map(
                    (u) => UserSearchGetResponse.fromJson(
                      u as Map<String, dynamic>,
                    ),
                  )
                  .toList() ??
              [];
        });
      }
    } catch (e) {
      log("Exception: $e");
    }
  }
}
