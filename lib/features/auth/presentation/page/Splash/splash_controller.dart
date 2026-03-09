

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashController extends GetxController {
  
  final RxBool isLoading = true.obs;

 // final GetUserUsecase getUserUsecase;

 // SplashController({required this.getUserUsecase,});

  @override
  void onInit() async {
    super.onInit();
    await checkUserSession();
    
    

  }


Future<void> checkUserSession() async {
  try {
   
   
  //  await getUserUsecase.execute();
    Get.offAllNamed(RoutesNames.preferencesPage);
  } catch (e) {
    Get.offAllNamed(RoutesNames.loginPage);
  } finally {
    isLoading.value = false;
  }
}

}