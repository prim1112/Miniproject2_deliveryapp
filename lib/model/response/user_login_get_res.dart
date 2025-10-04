import 'dart:convert';

UserLoginGetResponse userLoginGetResponseFromJson(String str) =>
    UserLoginGetResponse.fromJson(json.decode(str));

String userLoginGetResponseToJson(UserLoginGetResponse data) =>
    json.encode(data.toJson());

class UserLoginGetResponse {
  final String message;
  final Data data;

  UserLoginGetResponse({required this.message, required this.data});

  factory UserLoginGetResponse.fromJson(Map<String, dynamic> json) =>
      UserLoginGetResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  // ✅ user fields
  String? imageUser;
  int? userid;

  // ✅ rider fields
  String? imageRider;
  String? imageVehicle;
  String? licensePlate;
  int? riderId;

  // ✅ common fields
  String name;
  String phone;

  // ✅ เพิ่ม period
  int? period;

  Data({
    this.imageUser,
    this.userid,
    this.imageRider,
    this.imageVehicle,
    this.licensePlate,
    this.riderId,
    required this.name,
    required this.phone,
    this.period,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    imageUser: json["image_user"],
    userid: json["userid"],
    imageRider: json["image_rider"],
    imageVehicle: json["image_vehicle"],
    licensePlate: json["license_plate"],
    riderId: json["rider_id"],
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    period: json["period"], // ✅ map ค่า period จาก API
  );

  Map<String, dynamic> toJson() => {
    "image_user": imageUser,
    "userid": userid,
    "image_rider": imageRider,
    "image_vehicle": imageVehicle,
    "license_plate": licensePlate,
    "rider_id": riderId,
    "name": name,
    "phone": phone,
    "period": period, // ✅ ส่งออก JSON ด้วย
  };
}
