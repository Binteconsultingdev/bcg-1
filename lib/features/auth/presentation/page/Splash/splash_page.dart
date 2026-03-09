import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/auth/presentation/page/Splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
      final SplashController controller = Get.find<SplashController>();

  return Scaffold(
    backgroundColor: ThemeColor.backgroundColor,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ThemeColor.createAppLogo(size: 250,padding: EdgeInsets.only(bottom: 20)),
           
            ],
          ),
        ),
      ),
    ),
  );
}
}