import 'package:get/get.dart';
import 'package:reminder_app/controllers/add_medication_controller.dart';
import 'package:reminder_app/controllers/chatbot_controller.dart';
import 'package:reminder_app/controllers/medication_log_controller.dart';
import 'package:reminder_app/controllers/medications_controller.dart';
import 'package:reminder_app/controllers/navigation_controller.dart';
import 'package:reminder_app/controllers/profile_controller.dart';
import 'package:reminder_app/controllers/splash_screen_controller.dart';
import 'package:reminder_app/controllers/upload_documents_controller.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/controllers/home_controller.dart';
import 'package:reminder_app/controllers/login_controller.dart';
import 'package:reminder_app/controllers/nearby_pharmacies_controller.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/controllers/registration_controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}


class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}


class NearbyPharmaciesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.put<ConnectivityService>(ConnectivityService());
    }

    if (!Get.isRegistered<PharmaciesService>()) {
      Get.lazyPut<PharmaciesService>(() => PharmaciesService());
    }

    if (!Get.isRegistered<NearbyPharmaciesController>()) {
      Get.lazyPut<NearbyPharmaciesController>(
        () => NearbyPharmaciesController(),
      );
    }
  }
}

class MedicationLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicationLogController>(() => MedicationLogController());
  }
}

class AddMedicationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMedicationController>(() => AddMedicationController());
  }
}

class MedicationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MedicationsController());
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}

class DocumentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UploadDocumentsController());
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}

class ChatBotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
