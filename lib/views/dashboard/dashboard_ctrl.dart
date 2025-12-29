import 'package:get/get.dart';
import 'package:prime_health_patients/service/calling_init_method.dart';

class DashboardCtrl extends GetxController {

  @override
  void onInit() {
    Future.delayed(Duration.zero, () async => await CallingInitMethod().initData());
    super.onInit();
  }
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
