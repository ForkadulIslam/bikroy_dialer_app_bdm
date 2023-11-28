import 'dart:convert';


import 'package:bikroy_dialer/utility/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bikroy_dialer/Model/Employee.dart';
import 'package:bikroy_dialer/screen/Dashboard.dart';
import 'package:bikroy_dialer/utility/Colors.dart';
import 'package:bikroy_dialer/utility/ElevatedButtonStyle.dart';
import 'package:bikroy_dialer/utility/InputDecoration.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _loginForm = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool progressVisibility = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          //padding: EdgeInsets.all(10),
          child: Form(
            key: _loginForm,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientStart,gradientEnd
                      ],
                      end: Alignment.bottomCenter,
                      begin: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100))
                  ),
                  child: Center(
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height*0.6,
                  //height: double.infinity,
                  padding: EdgeInsets.all(20),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration:BoxDecoration(
                            color: Color(0xffffffff)
                        ),
                        child: TextFormField(
                          validator: (value){
                            if(value!.isEmpty){
                              return 'Employee ID is required';
                            }else{
                              return null;
                            }
                          },
                          decoration: buildInputDecoration('Login ID', Icons.person_outline),
                          maxLength: 30,
                          keyboardType: TextInputType.text,
                          controller: phoneNumberController,
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        decoration:BoxDecoration(
                            color: Color(0xffffffff)
                        ),
                        child: TextFormField(
                          obscureText: true,
                          validator: (value){
                            if(value!.isEmpty){
                              return 'Password is required';
                            }else{
                              return null;
                            }
                          },
                          decoration: buildInputDecoration('Password', Icons.phone),
                          maxLength: 6,
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                        ),
                      ),
                      SizedBox(height: 20),
                      Visibility(
                          maintainAnimation: true,
                          maintainState: true,
                          visible: progressVisibility,
                          child: Container(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: CircularProgressIndicator()
                          )
                      ),
                      buildElevatedButton('LOGIN', () async {
                        if(_loginForm.currentState!.validate()){
                          setState(() {
                            progressVisibility = true;
                          });
                          try {
                            Map<String, String> inputs_data = {
                              'login_id': phoneNumberController.text,
                              'password': passwordController.text,
                            };
                            String requestBody = jsonEncode(inputs_data);
                            //print(requestBody);
                            print('$apiBaseUrl/login');
                            var res = await http.post(
                                Uri.parse('$apiBaseUrl/login'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: requestBody
                            );
                            String resString = res.body.toString();

                            if(resString.isNotEmpty){
                              try{
                                Map<String, dynamic> resObj = jsonDecode(resString);
                                if(resObj['success']){
                                  final sharedPreference = await SharedPreferences.getInstance();
                                  sharedPreference.setString('login_id', resObj['data']['id'].toString());
                                  sharedPreference.setString('full_name', resObj['data']['full_name'].toString());
                                  sharedPreference.setString('roll_id', resObj['data']['roll_id'].toString());
                                  sharedPreference.setString('email', resObj['data']['email'].toString());
                                  int? parsedLoginId;
                                  if(resObj['data']['id'] is int){
                                    parsedLoginId = int.tryParse(resObj['data']['id'].toString());
                                  }else{
                                    print('Id is not int');
                                  }
                                  //print('Parsed login id: $parsedLoginId');
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => Dashboard(parsedLoginId!))
                                  );
                                }else{
                                  _showToast(context,resObj['message']);
                                }
                              } catch(e){
                                _showToast(context,'Json parse error: $e');
                              }
                            }else{
                              print('Got it data from login API');
                            }
                            setState(() {
                              progressVisibility = false;
                            });
                          } catch (err) {
                            print(err);
                          }
                        }
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context,String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'CLEAR', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}


