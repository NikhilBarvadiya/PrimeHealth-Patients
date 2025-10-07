class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String city;
  final String state;
  final String address;
  final String fcmToken;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.city,
    required this.state,
    required this.address,
    required this.fcmToken,
  });
}
