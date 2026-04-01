import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String serverBase = dotenv.env['API_BASE'].toString();
  static const String accesos = "accesosbcg";
   static   const String licenseKey = 'licenseKeyey';

  
}