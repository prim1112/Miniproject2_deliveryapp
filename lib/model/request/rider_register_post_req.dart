// To parse this JSON data, do
//
//     final riderRegisterPostRequest = riderRegisterPostRequestFromJson(jsonString);

import 'dart:convert';

RiderRegisterPostRequest riderRegisterPostRequestFromJson(String str) =>
    RiderRegisterPostRequest.fromJson(json.decode(str));

String riderRegisterPostRequestToJson(RiderRegisterPostRequest data) =>
    json.encode(data.toJson());

class RiderRegisterPostRequest {
  String name;
  String phone;
  String password;
  String imageRider;
  String imageVehicle;
  String licensePlate;

  RiderRegisterPostRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.imageRider,
    required this.imageVehicle,
    required this.licensePlate,
  });

  factory RiderRegisterPostRequest.fromJson(Map<String, dynamic> json) =>
      RiderRegisterPostRequest(
        name: json["name"],
        phone: json["phone"],
        password: json["password"],
        imageRider: json["image_rider"],
        imageVehicle: json["image_vehicle"],
        licensePlate: json["license_plate"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "password": password,
    "image_rider": imageRider,
    "image_vehicle": imageVehicle,
    "license_plate": licensePlate,
  };
}
