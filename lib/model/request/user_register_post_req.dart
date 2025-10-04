// To parse this JSON data, do
//
//     final userRegisterPostRequest = userRegisterPostRequestFromJson(jsonString);

import 'dart:convert';

UserRegisterPostRequest userRegisterPostRequestFromJson(String str) =>
    UserRegisterPostRequest.fromJson(json.decode(str));

String userRegisterPostRequestToJson(UserRegisterPostRequest data) =>
    json.encode(data.toJson());

class UserRegisterPostRequest {
  String name;
  String phone;
  String imageUser;
  String password;

  UserRegisterPostRequest({
    required this.name,
    required this.phone,
    required this.imageUser,
    required this.password,
  });

  factory UserRegisterPostRequest.fromJson(Map<String, dynamic> json) =>
      UserRegisterPostRequest(
        name: json["name"],
        phone: json["phone"],
        imageUser: json["image_user"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "image_user": imageUser,
    "password": password,
  };
}
