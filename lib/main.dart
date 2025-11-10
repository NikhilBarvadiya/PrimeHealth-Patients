import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prime_health_patients/firebase_options.dart';
import 'package:prime_health_patients/service/calling_init_method.dart';
import 'package:prime_health_patients/service/calling_service.dart';
import 'package:prime_health_patients/utils/routes/route_methods.dart';
import 'package:prime_health_patients/utils/routes/route_name.dart';
import 'package:prime_health_patients/utils/theme/light.dart';
import 'package:prime_health_patients/views/preload.dart';
import 'package:prime_health_patients/views/restart.dart';
import 'package:toastification/toastification.dart';
import 'utils/config/app_config.dart';

Future<void> main() async {
  await GetStorage.init();
  GestureBinding.instance.resamplingEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Color(0xFF0D9488), statusBarIconBrightness: Brightness.light));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await CallingInitMethod().initData();
  await preload();
  runApp(const RestartApp(child: MyApp()));
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CallingService().handleBackgroundMessage(message);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        builder: (BuildContext context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget!,
          );
        },
        debugShowCheckedModeBanner: false,
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        getPages: AppRouteMethods.pages,
        initialRoute: AppRouteNames.splash,
      ),
    );
  }
}
