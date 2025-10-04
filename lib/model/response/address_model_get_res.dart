class AddressModel {
  final String addressId; // backend: string
  final int userId; // backend: number
  final String addressText;
  final String gps;

  AddressModel({
    required this.addressId,
    required this.userId,
    required this.addressText,
    required this.gps,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    addressId: json['address_id']?.toString() ?? '',
    userId: json['user_id'] is int
        ? json['user_id']
        : int.tryParse('${json['user_id']}') ?? 0,
    addressText: json['address_text']?.toString() ?? '',
    gps: json['gps']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'address_id': addressId,
    'user_id': userId,
    'address_text': addressText,
    'gps': gps,
  };
}
