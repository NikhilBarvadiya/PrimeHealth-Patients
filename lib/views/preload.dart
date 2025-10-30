import 'package:get/get.dart';
import 'package:prime_health_patients/service/location_service.dart';
import 'package:prime_health_patients/views/auth/auth_service.dart';

Future<void> preload() async {
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => LocationService().init());
}
