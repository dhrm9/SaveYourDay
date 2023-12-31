
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/home_page.dart';
import 'package:flutter_application_4/pages/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     //to check if user is logged in or not
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context , snapshot) {
          //user logged in
           if(snapshot.hasData){
            return  const HomePage();
           }

          //user not logged in
          else {
            return const LoginOrRegisterPage();
          }
        },
      )
    );
  }
}