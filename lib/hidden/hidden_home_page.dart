import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/model/user.dart';

class HiddenHomePage extends StatefulWidget {
  const HiddenHomePage({super.key});

  @override
  State<HiddenHomePage> createState() => _HiddenHomePageState();
}

class _HiddenHomePageState extends State<HiddenHomePage> {
  void updatePassword() {
    showDialog(
      context: context,
      builder: (builder) {
        String enteredPassword = ''; // Variable to store the entered password

        return AlertDialog(
          title: const Text('Password'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              enteredPassword = value;
            },
            decoration: const InputDecoration(
              labelText: 'Enter new password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (enteredPassword.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(MyUser.instance!.userId)
                        .update({
                      'password': enteredPassword,
                      // Add other fields to update as needed
                    });
                    MyUser.instance!.password = enteredPassword;
                    // print('Password  updated successfully!');
                    // print(MyUser.instance!.password);
                  } catch (error) {
                    print('Error updating password : $error');
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hidden page'),
        actions: [
          IconButton(
              onPressed: updatePassword,
              icon: const Icon(Icons.password_outlined))
        ],
      ),
    );
  }
}
