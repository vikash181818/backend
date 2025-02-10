class AddressModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? houseNumber;
  final String? address;
  final String? landmark;
  final String? street;
  final int? isActive;
  final String? addressType;
  final int? defaultAddress;
  final String? createdDate;
  final String? lastUpdatedDate;
  final String? userId;
  final String? pincodeId;
  final String? cityId;
  final String? stateId;
  final String? createdById;
  final String? lastUpdatedById;

  // Add new fields for resolved names
  String? city;
  String? state;
  String? pincode;

  AddressModel({
    this.id,
    this.firstName,
    this.lastName,
    this.houseNumber,
    this.address,
    this.landmark,
    this.street,
    this.isActive,
    this.addressType,
    this.defaultAddress,
    this.createdDate,
    this.lastUpdatedDate,
    this.userId,
    this.pincodeId,
    this.cityId,
    this.stateId,
    this.createdById,
    this.lastUpdatedById,
    this.city,       // Resolved city name
    this.state,      // Resolved state name
    this.pincode,    // Resolved pincode
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      houseNumber: json['house_number'] as String?,
      address: json['address'] as String?,
      landmark: json['landmark'] as String?,
      street: json['street'] as String?,
      isActive: json['is_active'] as int?,
      addressType: json['address_type'] as String?,
      defaultAddress: json['default_address'] as int?,
      createdDate: json['created_date'] as String?,
      lastUpdatedDate: json['last_updated_date'] as String?,
      userId: json['userId'] as String?,
      pincodeId: json['pincodeId'] as String?,
      cityId: json['cityId'] as String?,
      stateId: json['stateId'] as String?,
      createdById: json['createdById'] as String?,
      lastUpdatedById: json['lastUpdatedById'] as String?,
    );
  }

  get line1 => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'house_number': houseNumber,
      'address': address,
      'landmark': landmark,
      'street': street,
      'is_active': isActive,
      'address_type': addressType,
      'default_address': defaultAddress,
      'created_date': createdDate,
      'last_updated_date': lastUpdatedDate,
      'userId': userId,
      'pincodeId': pincodeId,
      'cityId': cityId,
      'stateId': stateId,
      'createdById': createdById,
      'lastUpdatedById': lastUpdatedById,
    };
  }
}
