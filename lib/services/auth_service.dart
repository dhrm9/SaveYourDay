import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      gUser = await _googleSignIn.signIn();
      if (gUser != null) {
        GoogleSignInAuthentication? gAuth = await gUser!.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken,
        );
        try {
          UserCredential userCredential =
              await auth.signInWithCredential(credential);
          User user = userCredential.user!;

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'email': user.email,
              'password': "",
              'tasks': [],
              'userId': user.uid
            });
          }
        } catch (e) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        const snackBar = SnackBar(content: Text("Not able to sign in"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> googleSignOut() async{
    gUser = await _googleSignIn.signOut();
  }
}
