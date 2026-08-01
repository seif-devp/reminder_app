import 'package:get/get.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/data/entity/users.dart';

class ProfileService extends GetxService {
  Future<void> updateUserOnSupabase(User user) async {
    await cloud.from('users').update({
      'name': user.name,
      'gender': user.gender,
      'age': user.age,
      'blood_type': user.bloodType,
      'weight': user.weight,
      'height': user.height,
    }).eq('user_id', user.userId);
  }
}
