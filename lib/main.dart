
import 'package:flutter/material.dart';

import 'package:bikroy_dialer/screen/SplashPage.dart';


Future<void> main() async {

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dialer APP',
      home: SplashPage(),
    );
  }
}

