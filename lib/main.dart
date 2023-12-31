import 'package:flutter/material.dart';
import 'package:flutter_application_4/model/task.dart';
import 'package:flutter_application_4/notification_Service/notifi_service.dart';
import 'package:flutter_application_4/pages/auth_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
 

  Hive.registerAdapter(TaskAdapter());
  
  //initalize the hive 
  await Hive.initFlutter(); 

  //open a box 
  await Hive.openBox('mybox');

  //run the MYApp 
  runApp(const MyApp());
}

//class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: const AuthPage(),
     theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}