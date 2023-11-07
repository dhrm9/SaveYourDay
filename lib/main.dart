import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/auth_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //initalize the hive 
  await Hive.initFlutter();

  //open a box 
  
  var box = await Hive.openBox('mybox');

  //run the MYApp 
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: AuthPage(),
     theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}