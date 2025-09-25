import 'dart:convert';

// Deserialize JSON → Address
Address addressFromJson(String str) => Address.fromJson(json.decode(str));

// Serialize Address → JSON
String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  String userid;
  String addressText;
  String gps;

  Address({required this.userid, required this.addressText, required this.gps});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    userid: json['userid'],
    addressText: json['address_text'],
    gps: json['gps'],
  );

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'address_text': addressText,
    'gps': gps,
  };
}
