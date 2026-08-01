class UserModel {
  int? userId;
  String name;
  String email;
  String password;
  String gender;
  String age;
  String bloodType;
  double weight;
  double height;

  UserModel({
    this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.age,
    required this.bloodType,
    required this.weight,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
      'age': age,
      'blood_type': bloodType,
      'weight': weight,
      'height': height,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      gender: map['gender'],
      age: map['age'],
      bloodType: map['blood_type'],
      weight: map['weight'],
      height: map['height'],
    );
  }
}
