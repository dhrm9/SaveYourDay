import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/my_button.dart';
import 'package:flutter_application_4/components/my_textfield.dart';
import 'package:flutter_application_4/components/square_tile.dart';
import 'package:flutter_application_4/services/auth_service.dart';

class LoginPage extends StatefulWidget {
   final Function()? onTap;
   const LoginPage({
    super.key,
    required this.onTap,
    });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
 
  //text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

//sign user in method
  void signUserIn() async {
    //progress indicator
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
       
       Navigator.pop(context);

      showErrorMessage(e.code);
    }
  }

  //wrong credentials method
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              //logo
          
              const Icon(
                Icons.lock_person,
                size: 100,
              ),
          
              const SizedBox(height: 50),
          
              //welcome back your have been misse d
              Text(
                'Welcome back you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
          
              const SizedBox(height: 25),
          
              //user textfield
              MyTextField(
                controller: emailController,
                hintText: 'Email/Username',
                obscureText: false,
              ),
          
              const SizedBox(height: 10),
              //password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
          
              const SizedBox(height: 10),
              //forgot password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 25),
          
              //sign in button
              MyButton(
                text: "Sign In",
                onTap: signUserIn,
              ),
          
              const SizedBox(height: 30),
              //or continue with goggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              //google 
          
              const SizedBox(height: 30),
          
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareTile(
                    onTap: () => AuthService().googleSignIn(context),
                    imagePath: 'lib/images/gogle.png'),
                ],
              ),
          
              const SizedBox(height: 25),
              
              //not a memeber ? register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
