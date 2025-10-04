import 'package:dalivery_application/model/response/address_model_get_res.dart';

class UserModel {
  final int userid;
  final String name;
  final String phone;
  final String? imageUser;
  final List<AddressModel> addresses;

  UserModel({
    required this.userid,
    required this.name,
    required this.phone,
    this.imageUser,
    this.addresses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final addrsJson = (json['addresses'] as List?) ?? const [];
    final addresses = addrsJson
        .whereType<Map<String, dynamic>>()
        .map(AddressModel.fromJson)
        .toList();

    return UserModel(
      userid: int.tryParse(json['userid']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      imageUser: json['image_user']?.toString(),
      addresses: addresses,
    );
  }

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'name': name,
    'phone': phone,
    'image_user': imageUser,
    'addresses': addresses.map((e) => e.toJson()).toList(),
  };
}
