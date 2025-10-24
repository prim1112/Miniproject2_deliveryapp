import 'package:flutter/material.dart';
import 'package:dalivery_application/model/response/user_login_get_res.dart';

class UserDataProvider with ChangeNotifier {
  Data _datauser = Data(name: "", phone: "");

  Data get datauser => _datauser;

  void setDataUser(Data user) {
    _datauser = user;
    notifyListeners();
  }

  // ✅ จัดการ period
  void setPeriod(int period) {
    _datauser.period = period;
    notifyListeners();
  }

  int? getPeriod() => _datauser.period;

  // ✅ จัดการรูป
  void updateUserProfileImage(String newProfileImage) {
    _datauser.imageUser = newProfileImage;
    notifyListeners();
  }

  void updateRiderProfileImage(String newProfileImage) {
    _datauser.imageRider = newProfileImage;
    notifyListeners();
  }
}
