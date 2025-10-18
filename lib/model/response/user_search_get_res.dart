class UserSearchGetResponse {
  int user_id; // ✅ ตรงกับ backend
  String name;
  String phone;
  String? password;
  String? image_user; // ✅ ตรงกับ backend
  String? address_text; // ✅ ตรงกับ backend
  double? lat;
  double? long;
  String? gps;

  UserSearchGetResponse({
    required this.user_id,
    required this.name,
    required this.phone,
    this.password,
    this.image_user,
    this.address_text,
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
      user_id: json["user_id"] ?? 0, // ✅ ชื่อเดียวกับ backend
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
      password: json["password"],
      image_user: json["image_user"],
      address_text: json["address_text"],
      lat: parseLat,
      long: parseLong,
      gps: gpsStr,
    );
  }

  Map<String, dynamic> toJson() => {
    "user_id": user_id,
    "name": name,
    "phone": phone,
    "password": password,
    "image_user": image_user,
    "address_text": address_text,
    "gps": gps,
  };
}
