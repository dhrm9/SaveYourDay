import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
    
    FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> googleSignIn(BuildContext context) async {
    try {
        GoogleSignInAccount? gUser = await  _googleSignIn.signIn();
        if(gUser!=null){
          GoogleSignInAuthentication? gAuth = await gUser.authentication;

          AuthCredential credential = GoogleAuthProvider.credential(
            idToken: gAuth.idToken,
            accessToken: gAuth.accessToken, 
          );
           try{
           UserCredential userCredential = 
            await auth.signInWithCredential(credential);
           } catch(e) {
                final snackBar = SnackBar(content: Text(e.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          
        } else {
          final snackBar = SnackBar(content: Text("Not able to sign in"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }
    } catch (e) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
