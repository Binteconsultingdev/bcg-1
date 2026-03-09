import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'start_controller.dart';


class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StartController controller = Get.put(StartController());

    return Obx(() => ThemeColor.createMainScaffold(
  body: controller.currentPage,
  currentIndex: controller.selectedIndex.value,
  onNavigationTap: controller.changePage,
  iconPaths: controller.iconPaths,
  labels: controller.labels, 
  backgroundColor: ThemeColor.backgroundColorfondo,
  bottomNavBackgroundColor: Colors.white,
));
  }
}