import 'package:bcg/app.dart';
import 'package:bcg/common/settings/enviroment.dart';
import 'package:bcg/framework/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String enviromentSelect = Enviroment.testing.value;
                            
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await PreferencesUser().initiPrefs();

  print('=========ENVIROMENT SELECTED: $enviromentSelect');
  await dotenv.load(fileName: enviromentSelect);

  runApp(const App());
}
  