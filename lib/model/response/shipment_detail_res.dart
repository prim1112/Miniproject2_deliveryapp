import 'dart:convert';

// ✅ ฟังก์ชันแปลง JSON → Object
ShipmentFullDetailRes shipmentFullDetailResFromJson(String str) =>
    ShipmentFullDetailRes.fromJson(json.decode(str));

String shipmentFullDetailResToJson(ShipmentFullDetailRes data) =>
    json.encode(data.toJson());

class ShipmentFullDetailRes {
  int shipmentId;
  int senderId;
  int receiverId;
  int pickupAddressId;
  int deliveryAddressId;
  Receiver sender;
  Receiver receiver;
  Address pickupAddress;
  Address deliveryAddress;
  List<Product> products;
  List<ShipmentPhoto> shipmentPhotos;

  // ✅ เพิ่มฟิลด์สำหรับตำแหน่งไรเดอร์
  double? riderLatitude;
  double? riderLongitude;

  ShipmentFullDetailRes({
    required this.shipmentId,
    required this.senderId,
    required this.receiverId,
    required this.pickupAddressId,
    required this.deliveryAddressId,
    required this.sender,
    required this.receiver,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.products,
    required this.shipmentPhotos,
    this.riderLatitude,
    this.riderLongitude,
  });

  factory ShipmentFullDetailRes.fromJson(Map<String, dynamic> json) =>
      ShipmentFullDetailRes(
        shipmentId: json["shipment_id"] ?? 0,
        senderId: json["sender_id"] ?? 0,
        receiverId: json["receiver_id"] ?? 0,
        pickupAddressId: json["pickup_address_id"] ?? 0,
        deliveryAddressId: json["delivery_address_id"] ?? 0,
        sender: Receiver.fromJson(json["sender"] ?? {}),
        receiver: Receiver.fromJson(json["receiver"] ?? {}),
        pickupAddress: Address.fromJson(json["pickupAddress"] ?? {}),
        deliveryAddress: Address.fromJson(json["deliveryAddress"] ?? {}),
        products: (json["products"] == null)
            ? []
            : List<Product>.from(
                json["products"].map((x) => Product.fromJson(x)),
              ),
        shipmentPhotos: (json["shipment_photos"] == null)
            ? []
            : List<ShipmentPhoto>.from(
                json["shipment_photos"].map((x) => ShipmentPhoto.fromJson(x)),
              ),

        // ✅ รองรับข้อมูลตำแหน่งไรเดอร์จาก backend
        riderLatitude: json["rider_latitude"] != null
            ? double.tryParse(json["rider_latitude"].toString())
            : null,
        riderLongitude: json["rider_longitude"] != null
            ? double.tryParse(json["rider_longitude"].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
    "shipment_id": shipmentId,
    "sender_id": senderId,
    "receiver_id": receiverId,
    "pickup_address_id": pickupAddressId,
    "delivery_address_id": deliveryAddressId,
    "sender": sender.toJson(),
    "receiver": receiver.toJson(),
    "pickupAddress": pickupAddress.toJson(),
    "deliveryAddress": deliveryAddress.toJson(),
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
    "shipment_photos": List<dynamic>.from(
      shipmentPhotos.map((x) => x.toJson()),
    ),

    // ✅ เพิ่มกลับตอนส่งออก
    "rider_latitude": riderLatitude,
    "rider_longitude": riderLongitude,
  };
}

// 👤 ผู้ใช้ (sender / receiver)
class Receiver {
  int userId;
  String name;
  String phone;
  String imageUser;

  Receiver({
    required this.userId,
    required this.name,
    required this.phone,
    required this.imageUser,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    userId: json["user_id"] ?? 0,
    name: json["name"] ?? "-",
    phone: json["phone"] ?? "-",
    imageUser: json["image_user"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "phone": phone,
    "image_user": imageUser,
  };
}

// 🏠 ที่อยู่
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
    addressId: json["address_id"] ?? 0,
    addressText: json["address_text"] ?? "-",
    latitude: (json["latitude"] ?? 0).toDouble(),
    longitude: (json["longitude"] ?? 0).toDouble(),
    userId: json["user_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "address_id": addressId,
    "address_text": addressText,
    "latitude": latitude,
    "longitude": longitude,
    "user_id": userId,
  };
}

// 📦 สินค้า
class Product {
  int pid;
  int shipmentId;
  String details;
  String imageProduct;

  Product({
    required this.pid,
    required this.shipmentId,
    required this.details,
    required this.imageProduct,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    pid: json["pid"] ?? 0,
    shipmentId: json["shipment_id"] ?? 0,
    details: json["details"] ?? "",
    imageProduct: json["image_product"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "pid": pid,
    "shipment_id": shipmentId,
    "details": details,
    "image_product": imageProduct,
  };
}

// 📸 รูปภาพของ shipment (status 1–4)
class ShipmentPhoto {
  int? photoId;
  int? shipmentId;
  String? photoUrl;
  int? status;

  ShipmentPhoto({this.photoId, this.shipmentId, this.photoUrl, this.status});

  factory ShipmentPhoto.fromJson(Map<String, dynamic> json) => ShipmentPhoto(
    photoId: json["photo_id"],
    shipmentId: json["shipment_id"],
    photoUrl: json["photo_url"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "photo_id": photoId,
    "shipment_id": shipmentId,
    "photo_url": photoUrl,
    "status": status,
  };
}
