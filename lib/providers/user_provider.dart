import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var userId = ''.obs;
  var userName = ''.obs;

  /// โหลดข้อมูลจาก SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    userName.value = prefs.getString('userName') ?? '';
  }

  /// บันทึกข้อมูลผู้ใช้ (หลัง Login)
  Future<void> saveUser(String id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userName', name);
    userId.value = id;
    userName.value = name;
  }

  /// ล้างข้อมูล (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userId.value = '';
    userName.value = '';
  }
}
