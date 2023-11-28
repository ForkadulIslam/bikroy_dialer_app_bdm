import 'dart:convert';


import 'package:bikroy_dialer/myWidgets/ConditioningLoader.dart';
import 'package:call_log/call_log.dart';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/Colors.dart';
import 'package:http/http.dart' as http;

import '../utility/Constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LeadDetails extends StatefulWidget{

  final int lead_id;
  const LeadDetails({super.key, required this.lead_id});
  @override
  State<LeadDetails> createState() => _LeadDetailsState();
}

class _LeadDetailsState extends State<LeadDetails> with WidgetsBindingObserver{
  String? name, phone, category, date, location, query;
  TextEditingController callingStatusTypeController = TextEditingController();
  TextEditingController statusSubTypeController = TextEditingController();
  bool progressVisibility = true;
  late WebViewController controller;
  String initialUrl = "";
  bool proceedToSave = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && proceedToSave) {
      if (phone != null) {
        checkCallStatus(phone!);
        setState(() {
          proceedToSave = false;
        });
      }
    }
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setWebViewUrl();
    getQueuedLead();
    setWebViewUrl().whenComplete(() async {

      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
            },
            onPageStarted: (String url) {

            },
            onPageFinished: (String url) {
              setState(() {
                progressVisibility = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              print(error);
            },
            onNavigationRequest: (NavigationRequest request) {
              print('Navigation:'+request.url.toString());
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(initialUrl));
    });

    setState(() {
      proceedToSave = false;
    });

  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> setWebViewUrl() async {
    final sharedPreference = await SharedPreferences.getInstance();
    setState(() {
      this.initialUrl = 'https://bikroyit.com/lead_management/module/bdm_calling_queue_by_queue_id/'+sharedPreference.getString('login_id').toString()+'/'+widget.lead_id.toString();
    });
    print(this.initialUrl);
  }
  Future getQueuedLead() async {
    var res = await http.get(Uri.parse('$apiBaseUrl/queue_lead_details/'+widget.lead_id.toString()));
    if(res.body.isNotEmpty){
      Map<String, dynamic> resObj = jsonDecode(res.body.toString());
      if(resObj['success']){
        setState(() {
          name = resObj['response_date']['lead']['name'];
          phone = resObj['response_date']['lead']['phone'];
          category = resObj['response_date']['lead']['category'];
          date = resObj['response_date']['lead']['lead_date'];
          location = resObj['response_date']['lead']['location'];
          query = resObj['response_date']['lead']['query'];
        });
      }else{
        print(resObj['message']);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff098777),
          title: Text('Leads'),
          // Add a leading widget with a back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height*0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientStart,Color(0xff098777)
                          ],
                          end: Alignment.topCenter,
                          begin: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40),bottomRight: Radius.circular(40))
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric( horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name ?? '', style: TextStyle(fontSize: 18, color: Color(0xffdddddd))),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category ?? '', style: TextStyle(fontSize: 13, color: Color(0xffdddddd)),),
                              SizedBox(width: 5,),
                              Text('||',style: TextStyle(fontSize: 13, color: pinkColor),),
                              SizedBox(width: 5,),
                              Text(location ?? '', style: TextStyle(fontSize: 13, color: Color(0xffdddddd)),),
                              SizedBox(width: 5,),
                              Text('||',style: TextStyle(fontSize: 13, color: pinkColor),),
                              SizedBox(width: 5,),
                              Text(date ?? '', style: TextStyle(fontSize: 13, color: Color(0xffdddddd)),),
                            ],
                          ),
                          SizedBox(height: 15,),
                          Text(query ?? '', style: TextStyle(fontSize: 13, color: Color(0xffdddddd)),),
                          SizedBox(height: 5,),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: ()async{
                                Map<Permission, PermissionStatus> statuses = await [Permission.phone].request();
                                if (statuses[Permission.phone]!.isGranted) {
                                  call();
                                } else {
                                  print('No permission ...');
                                }

                              },
                              child: (phone != null) ? Icon(
                                size:40,
                                Icons.dialer_sip_outlined,
                                color: pinkColor,
                              ):CircularProgressIndicator(
                                color: pinkColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Container(
                  //height: MediaQuery.of(context).size.height*0.6,
                  //height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(progressVisibility)
                        ConditioningLoader(),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        //padding: EdgeInsets.symmetric(horizontal: 20),
                        child: WebViewWidget(
                          controller: controller,
                        ),
                      ),
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

  void call() async{
    print(phone);
    String? _phone = phone;
    bool? res = await FlutterPhoneDirectCaller.callNumber(_phone!);
    if (res == true) {
      proceedToSave = true; // Set the flag to check the call status
    }
  }


  Future<void> checkCallStatus(String phoneNumber) async {
    // Request permission
    
    var now = DateTime.now();
    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: now.subtract(Duration(days: 1)).millisecondsSinceEpoch,
    );
    int count = 1;
    for (var entry in entries) {
      if(count <=2){
        if (entry.number == phoneNumber) {
          print('-------------------------------------');
          // print('F. NUMBER  : ${entry.formattedNumber}');
          // print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
          print('NUMBER     : ${entry.number}');
          print('NAME       : ${entry.name}');
          print('TYPE       : ${entry.callType}');
          print('DATE       : ${DateFormat('yyyy-MM-dd:HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(entry.timestamp!))}');
          print('DURATION   : ${entry.duration}');
          // print('ACCOUNT ID : ${entry.phoneAccountId}');
          // print('ACCOUNT ID : ${entry.phoneAccountId}');
          // print('SIM NAME   : ${entry.simDisplayName}');
          print('-------------------------------------');
        }
        count++;
      }
    }
  }
}
