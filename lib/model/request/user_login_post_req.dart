import 'dart:convert';

UsersLoginPostRequest usersLoginPostRequestFromJson(String str) =>
    UsersLoginPostRequest.fromJson(json.decode(str));

String usersLoginPostRequestToJson(UsersLoginPostRequest data) =>
    json.encode(data.toJson());

class UsersLoginPostRequest {
  String phone;
  String password;

  UsersLoginPostRequest({required this.phone, required this.password});

  factory UsersLoginPostRequest.fromJson(Map<String, dynamic> json) =>
      UsersLoginPostRequest(phone: json["phone"], password: json["password"]);

  Map<String, dynamic> toJson() => {"phone": phone, "password": password};
}
