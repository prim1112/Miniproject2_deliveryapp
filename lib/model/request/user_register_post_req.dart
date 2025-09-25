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
  String password;
  String imageUser;

  UserRegisterPostRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.imageUser,
  });

  factory UserRegisterPostRequest.fromJson(Map<String, dynamic> json) =>
      UserRegisterPostRequest(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        imageUser: json["image_user"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "password": password,
    "image_user": imageUser,
  };
}
