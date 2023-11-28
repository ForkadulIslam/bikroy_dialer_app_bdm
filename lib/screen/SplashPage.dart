import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bikroy_dialer/screen/Login.dart';
import 'package:bikroy_dialer/screen/Dashboard.dart';
import 'package:bikroy_dialer/utility/Colors.dart';
import 'package:http/http.dart' as http;

int? login_id;
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin().whenComplete(() async {
      Timer(Duration(microseconds: 4000),(){
        Navigator.pushReplacement(
            context,MaterialPageRoute(builder: (context) => login_id == null ? const Login() : Dashboard(login_id!))
        );
      });
    });
  }

  Future checkLogin() async{
    final sharedPreference = await SharedPreferences.getInstance();
    final session_login_id = sharedPreference.getString('login_id');
    if(session_login_id != null){
      final parsedId = int.tryParse(session_login_id);
      if(parsedId != null){
        setState(() {
          login_id = parsedId;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientStart,gradientEnd
            ],
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          )
        ),
        child: Center(
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }
}
