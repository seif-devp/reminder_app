import 'package:floor/floor.dart';


@Entity(tableName: 'users')
class User {
  @PrimaryKey()
  final String userId;

  final String name;
  final String email;
  final String password;
  final String? gender;
  final String? age;
  final String? bloodType;
  final String? weight;
  final String? height;
  final String? syncStatus; // 'synced' or 'not_synced'

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    this.gender,
    this.age,
    this.bloodType,
    this.weight,
    this.height,
    this.syncStatus,
  });
}
