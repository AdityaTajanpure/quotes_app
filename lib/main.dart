import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotes_app/MainScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Quotes App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: MainScreen(),
    );
  }
}
