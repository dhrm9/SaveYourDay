import 'package:flutter/material.dart';

class HiddenHomePage extends StatefulWidget {
  const HiddenHomePage({super.key});

  @override
  State<HiddenHomePage> createState() => _HiddenHomePageState();
}

class _HiddenHomePageState extends State<HiddenHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('hidden page')),
    );
  }
}