import 'dart:convert';

// ✅ ฟังก์ชันแปลง JSON → Object
ShipmentFullDetailRes shipmentFullDetailResFromJson(String str) =>
    ShipmentFullDetailRes.fromJson(json.decode(str));

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
  });

  factory ShipmentFullDetailRes.fromJson(Map<String, dynamic> json) =>
      ShipmentFullDetailRes(
        shipmentId: json["shipment_id"],
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        pickupAddressId: json["pickup_address_id"],
        deliveryAddressId: json["delivery_address_id"],
        sender: Receiver.fromJson(json["sender"]),
        receiver: Receiver.fromJson(json["receiver"]),
        pickupAddress: Address.fromJson(json["pickupAddress"]),
        deliveryAddress: Address.fromJson(json["deliveryAddress"]),
        products: List<Product>.from(
          (json["products"] ?? []).map((x) => Product.fromJson(x)),
        ),
        shipmentPhotos: List<ShipmentPhoto>.from(
          (json["shipment_photos"] ?? []).map((x) => ShipmentPhoto.fromJson(x)),
        ),
      );
}

// ✅ ผู้ใช้ (sender / receiver)
class Receiver {
  String imageUser;
  String name;
  String password;
  String phone;
  int userId;

  Receiver({
    required this.imageUser,
    required this.name,
    required this.password,
    required this.phone,
    required this.userId,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    imageUser: json["image_user"],
    name: json["name"],
    password: json["password"],
    phone: json["phone"],
    userId: json["user_id"],
  );
}

// ✅ ที่อยู่
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
    addressId: json["address_id"],
    addressText: json["address_text"],
    latitude: json["latitude"].toDouble(),
    longitude: json["longitude"].toDouble(),
    userId: json["user_id"],
  );
}

// ✅ สินค้า
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
    pid: json["pid"],
    shipmentId: json["shipment_id"],
    details: json["details"] ?? "",
    imageProduct: json["image_product"] ?? "",
  );
}

// ✅ รูปภาพการจัดส่ง
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
}
