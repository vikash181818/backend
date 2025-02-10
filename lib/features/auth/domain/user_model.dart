class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final dynamic phone;
  final dynamic refCode;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.refCode,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      refCode: map['ref_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'ref_code': refCode,
    };
  }
}



