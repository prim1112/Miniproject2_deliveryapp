class UserSearchGetResponse {
  int userId;
  String name;
  String phone;
  String? password; // optional
  String? imageUser; // รูปโปรไฟล์
  String? address; // ข้อความที่อยู่
  double? lat; // ใช้ในแอพ
  double? long; // ใช้ในแอพ
  String? gps; // raw gps string จาก backend

  UserSearchGetResponse({
    required this.userId,
    required this.name,
    required this.phone,
    this.password,
    this.imageUser,
    this.address,
    this.lat,
    this.long,
    this.gps,
  });

  factory UserSearchGetResponse.fromJson(Map<String, dynamic> json) {
    double? parseLat;
    double? parseLong;
    final gpsStr = json["gps"]?.toString();

    if (gpsStr != null && gpsStr.contains(",")) {
      final parts = gpsStr.split(",");
      if (parts.length == 2) {
        parseLat = double.tryParse(parts[0].trim());
        parseLong = double.tryParse(parts[1].trim());
      }
    }

    return UserSearchGetResponse(
      userId: json["userid"],
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
      password: json["password"],
      imageUser: json["image_user"],
      address: json["address_text"],
      lat: parseLat,
      long: parseLong,
      gps: gpsStr,
    );
  }

  Map<String, dynamic> toJson() => {
    "userid": userId,
    "name": name,
    "phone": phone,
    "password": password,
    "image_user": imageUser,
    "address_text": address,
    "gps": gps, // ✅ ส่งกลับไปเป็น gps string
  };
}
