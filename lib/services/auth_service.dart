import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignInAccount? gUser;

  Future<void> googleSignIn(BuildContext context) async {
    try {
      gUser = await _googleSignIn.signIn(); // Attempt to sign in with Google

      if (gUser != null) {
        // If sign-in is successful, get authentication tokens
        GoogleSignInAuthentication? gAuth = await gUser!.authentication;
        AuthCredential credential = GoogleAuthProvider.credential( // Create a credential object
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken,
        );

        try {
          // Sign in to Firebase using the Google credential
          UserCredential userCredential =
              await auth.signInWithCredential(credential);
          User user = userCredential.user!; // Get the signed-in user

          // Check if the user document exists in the database
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // If the user document doesn't exist, create it
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'email': user.email, // Store the user's email address
              'password': "", // Store an empty password (since we're using Google authentication)
              'tasks': [], // Initialize an empty tasks list
              'userId': user.uid, // Store the user's ID
            });
          }

          // Navigate to the home page after successful sign-in
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        } catch (e) {
          // Handle any errors that occur during sign-in
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        // Show a snackbar if the user cancels the sign-in process
        const snackBar = SnackBar(content: Text("Not able to sign in"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      // Handle any general errors that occur during the sign-in process
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> googleSignOut() async {
    gUser = await _googleSignIn.signOut(); // Sign out of Google
  }
}

