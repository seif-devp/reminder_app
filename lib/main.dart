import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:reminder_app/controllers/notification_controller.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/services/chatbot_service.dart';
import 'package:reminder_app/services/documents_service.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/core/binding_classes.dart';
import 'package:reminder_app/services/connectivity_service.dart';
import 'package:reminder_app/services/medications_service.dart';
import 'package:reminder_app/services/notification_service.dart';
import 'package:reminder_app/services/profile_service.dart';
import 'package:reminder_app/services/records_service.dart';
import 'package:reminder_app/services/schedules_service.dart';
import 'package:reminder_app/services/sync_service.dart';
import 'package:reminder_app/services/theme_service.dart';
import 'package:reminder_app/services/tts_service.dart';
import 'package:reminder_app/theme/app_theme.dart';
import 'package:reminder_app/views/add_medication_page.dart';
import 'package:reminder_app/views/chatbot_page.dart';
import 'package:reminder_app/views/home_page.dart';
import 'package:reminder_app/views/login_page.dart';
import 'package:reminder_app/views/main_navigation.dart';
import 'package:reminder_app/views/medication_log_page.dart';
import 'package:reminder_app/views/medications_page.dart';
import 'package:reminder_app/views/nearby_pharmacies_page.dart';
import 'package:reminder_app/services/pharmacies_service.dart';
import 'package:reminder_app/views/profile_page.dart';
import 'package:reminder_app/views/registration_page.dart';
import 'package:reminder_app/views/splash_screen.dart';
import 'package:reminder_app/views/upload_documents_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  await NotificationService().initialize();
  await NotificationService().takePermission();
  await TtsService().initialize();
  // 4. Setup listeners with top-level functions
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  );
  await GetStorage.init();
  await Supabase.initialize(
    url: 'https://rauyhbcxlbpsxlemntsz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhdXloYmN4bGJwc3hsZW1udHN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjI1NjUsImV4cCI6MjA3ODA5ODU2NX0.LpMWrdD4z9VH7nyffp8stJp3U4CEUt0-1uOmMx8nfG8',
  );
  runApp(const MyApp());
}

final cloud = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  StreamSubscription? _globalConnectivitySub;
  bool _wasOnline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startGlobalConnectivityListener();
    });
  }

  Future<void> startGlobalConnectivityListener() async {
    try {
      final connectivityService = Get.find<ConnectivityService>();
      final syncService = Get.find<SyncService>();

      _wasOnline = await connectivityService.connected();

      _globalConnectivitySub = connectivityService.checkforInternet().listen((
        result,
      ) async {
        final isOnlineNow = await connectivityService.connected();

        if (isOnlineNow && !_wasOnline) {
          _wasOnline = true;

          try {
            await syncService.syncAll();
          } catch (e) {
            print('Sync failed: $e');
          }
        } else if (!isOnlineNow && _wasOnline) {
          _wasOnline = false;
        }
      });
    } catch (e) {
      print('Failed to start listener: $e');
    }
  }

  @override
  void dispose() {
    _globalConnectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeService().theme,
      initialRoute: '/splash',
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => AuthService(), fenix: true);
        Get.lazyPut(() => ConnectivityService(), fenix: true);
        Get.lazyPut(() => PharmaciesService());
        Get.lazyPut(() => DocumentsService());
        Get.lazyPut(() => MedicationsService());
        Get.lazyPut(() => SchedulesService());
        Get.lazyPut(() => RecordsService());
        Get.lazyPut(() => ProfileService());
        Get.lazyPut<ChatbotService>(() => ChatbotService());
        Get.put(SyncService(), permanent: true);
      }),
      getPages: [
        GetPage(
          name: '/main',
          page: () => MainNavigation(),
          binding: NavigationBinding(),
        ),
        GetPage(
          name: '/splash',
          page: () => SplashScreen(),
          binding: SplashBinding(),
        ),
        GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => SignUpView(),
          binding: SignUpBinding(),
        ),
        GetPage(
          name: '/nearbyPharmacies',
          page: () => NearbyPharmaciesPage(),
          binding: NearbyPharmaciesBinding(),
        ),
        GetPage(
          name: '/medicationLog',
          page: () => MedicationLogPage(),
          binding: MedicationLogBinding(),
        ),
        GetPage(
          name: '/addMedication',
          page: () => AddMedicationPage(),
          binding: AddMedicationBinding(),
        ),
        GetPage(
          name: '/medications',
          page: () => MedicationsPage(),
          binding: MedicationsBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfilePage(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: '/documents',
          page: () => UploadDocumentspage(),
          binding: DocumentBinding(),
        ),
        GetPage(
          name: '/chatbot',
          page: () => ChatbotPage(),
          binding: ChatBotBinding(),
        ),
      ],
    );
  }
}
