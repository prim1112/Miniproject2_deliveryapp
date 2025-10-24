import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  // ✅ ตัวแปรเก็บข้อมูล user
  UserProfile _userProfile = UserProfile();
  String userId = '';

  int? _createdShipmentId;
  int? get createdShipmentId => _createdShipmentId;

  // ✅ SET method สำหรับเปลี่ยน user profile
  void setUserProfile(int id, String name) {
    _userProfile = UserProfile()
      ..user_id = id
      ..name = name;
    notifyListeners();
  }

  // ✅ getter สำหรับอ่านจากหน้าอื่น
  UserProfile get userProfile => _userProfile;

  // ✅ set เฉพาะ userId (ถ้าจำเป็น)
  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }

  String get getUserId => userId;

  // ✅ ฟังก์ชันเก็บ shipment_id หลังสร้างสำเร็จ
  void setCreatedShipmentId(int id) {
    _createdShipmentId = id;
    notifyListeners();
  }

  // ✅ รีเซ็ต shipment id (ถ้าต้องการใช้ใหม่)
  void clearShipmentId() {
    _createdShipmentId = null;
    notifyListeners();
  }
}

class UserProfile {
  int user_id = 0;
  String name = '';
}
