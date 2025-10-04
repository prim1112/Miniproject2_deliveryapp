// import 'dart:convert';

// // Deserialize JSON → Address
// Address addressFromJson(String str) => Address.fromJson(json.decode(str));

// // Serialize Address → JSON
// String addressToJson(Address data) => json.encode(data.toJson());

// class Address {
//   String userid;
//   String addressText;
//   String gps;

//   Address({required this.userid, required this.addressText, required this.gps});

//   factory Address.fromJson(Map<String, dynamic> json) => Address(
//     userid: json['userid'],
//     addressText: json['address_text'],
//     gps: json['gps'],
//   );

//   Map<String, dynamic> toJson() => {
//     'userid': userid,
//     'address_text': addressText,
//     'gps': gps,
//   };
// }

import 'dart:convert';

// Deserialize JSON → Address
Address addressFromJson(String str) => Address.fromJson(json.decode(str));

// Serialize Address → JSON
String addressToJson(Address data) => json.encode(data.toJson());

class Address {
  int userid;
  String addressText;
  String gps;

  Address({required this.userid, required this.addressText, required this.gps});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    userid: json['userid'] is int
        ? json['userid'] as int
        : int.parse(json['userid'].toString()), // ⭐ รองรับ string ด้วย
    addressText: json['address_text'] as String,
    gps: json['gps'] as String,
  );

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'address_text': addressText,
    'gps': gps,
  };
}
