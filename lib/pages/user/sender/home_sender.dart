import 'dart:convert';
import 'dart:developer';
import 'package:dalivery_application/config/config.dart';
import 'package:dalivery_application/model/response/user_search_get_res.dart';
import 'package:dalivery_application/pages/user/sender/product_list.dart';
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
  bool isLoading = false;
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig()
        .then((value) {
          url = value['apiEndpoint'];
          log(value['apiEndpoint']);

          final appData = Provider.of<AppData>(context, listen: false);
          final int senderId = appData.userProfile.user_id;
          _fetchUsers("", senderId);
        })
        .catchError((err) {
          log(err.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final String userName = appData.userProfile.name;
    final int senderId = appData.userProfile.user_id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFCC0033),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
                  userName,
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
                _fetchUsers(value, senderId);
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
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: user.image_user != null
                                  ? NetworkImage(user.image_user!)
                                  : const AssetImage(
                                          "assets/images/unnamed.webp",
                                        )
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
                      },
                    ),
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

      setState(() => isLoading = true);

      final response = await http.get(apiUrl);

      log("STATUS: ${response.statusCode}");
      log("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic>? usersJson = data["users"];

        if (usersJson != null && usersJson.isNotEmpty) {
          setState(() {
            users = usersJson
                .where((u) => u != null) // 🔒 ป้องกัน null
                .map(
                  (u) =>
                      UserSearchGetResponse.fromJson(u as Map<String, dynamic>),
                )
                .toList();
          });
        } else {
          setState(() => users = []);
        }
      } else {
        setState(() => users = []);
      }
    } catch (e) {
      log("Exception: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
