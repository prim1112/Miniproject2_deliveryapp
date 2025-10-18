// To parse this JSON data, do
//
//     final userOrderInfoRes = userOrderInfoResFromJson(jsonString);

import 'dart:convert';

UserOrderInfoRes userOrderInfoResFromJson(String str) =>
    UserOrderInfoRes.fromJson(json.decode(str));

String userOrderInfoResToJson(UserOrderInfoRes data) =>
    json.encode(data.toJson());

class UserOrderInfoRes {
  Receiver sender;
  Receiver receiver;

  UserOrderInfoRes({required this.sender, required this.receiver});

  factory UserOrderInfoRes.fromJson(Map<String, dynamic> json) =>
      UserOrderInfoRes(
        sender: Receiver.fromJson(json["sender"]),
        receiver: Receiver.fromJson(json["receiver"]),
      );

  Map<String, dynamic> toJson() => {
    "sender": sender.toJson(),
    "receiver": receiver.toJson(),
  };
}

class Receiver {
  String imageUser;
  String name;
  String password;
  String phone;
  int userId;
  List<Address> addresses;

  Receiver({
    required this.imageUser,
    required this.name,
    required this.password,
    required this.phone,
    required this.userId,
    required this.addresses,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    imageUser: json["image_user"],
    name: json["name"],
    password: json["password"],
    phone: json["phone"],
    userId: json["user_id"],
    addresses: List<Address>.from(
      json["addresses"].map((x) => Address.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "image_user": imageUser,
    "name": name,
    "password": password,
    "phone": phone,
    "user_id": userId,
    "addresses": List<dynamic>.from(addresses.map((x) => x.toJson())),
  };
}

class Address {
  int addressId;
  String addressText;
  double latitude;
  double longitude;
  int userId;

  Address({
    required this.addressId,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressId: json["address_id"],
    addressText: json["address_text"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    userId: json["user_id"],
  );

  Map<String, dynamic> toJson() => {
    "address_id": addressId,
    "address_text": addressText,
    "latitude": latitude,
    "longitude": longitude,
    "user_id": userId,
  };
}
