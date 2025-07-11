import 'package:ente_assignment/pages/home_page.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => HomePage(),
      }
    );
  }
}