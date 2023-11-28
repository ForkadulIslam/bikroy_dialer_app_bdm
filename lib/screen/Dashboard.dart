import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bikroy_dialer/myWidgets/MyLeads.dart';
import 'package:bikroy_dialer/screen/LeadDetails.dart';
import 'package:bikroy_dialer/utility/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bikroy_dialer/screen/Login.dart';
import 'package:bikroy_dialer/utility/Colors.dart';
import 'package:http/http.dart' as http;


class Dashboard extends StatefulWidget {

  final int login_id;
  Dashboard(this.login_id);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  String full_name = '';
  String role_id = '';
  String user_id = '';
  String email = '';
  List<Map<String, dynamic>> myLeads = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }




  Future getUserData() async {
    //print('Get user data fired...');
    final sharedPreference = await SharedPreferences.getInstance();
    user_id = (await sharedPreference.getString('login_id'))!;
    full_name = sharedPreference.getString('full_name')!;
    email = sharedPreference.getString('email')!;
    //print(full_name);
    var res = await http.get(Uri.parse('$apiBaseUrl/lead_by_user_id/'+user_id));
    if(res.body.isNotEmpty){
      String resString = res.body.toString();
      Map<String, dynamic> resObj = jsonDecode(resString);
      if(resObj['success']){
        List<Map<String, dynamic>> responseList = (resObj['response_data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
        setState(() {
          myLeads = responseList;
        });
      }else{
        print(resObj['message']);
      }
    }
  }

  Future<void> _refreshData() async {
    await getUserData();
    print('Refresh data ');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: MediaQuery.of(context).size.height*0.2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            gradientStart,gradientEnd
                          ],
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40),bottomRight: Radius.circular(40))
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric( horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            email,
                            style: TextStyle(color: Colors.white),
                            maxFontSize: 25,
                            minFontSize: 17,
                          ),
                          SizedBox(height: 10,),
                          InkWell(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();

                              // Remove the stored user-related data
                              prefs.remove('login_id');
                              prefs.remove('full_name');
                              prefs.remove('roll_id');
                              prefs.remove('email');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Login(), // Replace 'LoginPage' with your actual login page widget
                                ),
                              );
                            },
                            child: Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                color: gradientEnd, // Background color
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // Shadow color
                                    spreadRadius: 2, // Spread radius
                                    blurRadius: 5, // Blur radius
                                    offset: Offset(0, 3), // Shadow offset
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.white, // Text color
                                    fontSize: 13, // Text size
                                    fontWeight: FontWeight.bold, // Text boldness
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                SizedBox(height: 20,),
                Expanded(
                  child:SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      //padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Scrollable(
                        viewportBuilder: (BuildContext context, ViewportOffset offset){
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Name',style: TextStyle(fontSize: 12)), numeric: false),
                                DataColumn(label: Text('Category',style: TextStyle(fontSize: 12)), numeric: false),
                                DataColumn(label: Text('Location',style: TextStyle(fontSize: 12)), numeric: false),
                                DataColumn(label: Text('Date',style: TextStyle(fontSize: 12)), numeric: false),
                              ],
                              rows: myLeads.map((lead) {
                                return DataRow(cells: [
                                  DataCell(
                                    InkWell(
                                      onTap: () async{

                                        final lead_id = lead['id'];

                                        var getBack = await Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) =>LeadDetails(lead_id: lead_id)));

                                        if(getBack != null || getBack == true){
                                          await _refreshData();
                                        }

                                      },
                                      child: Container(
                                        width:100,
                                        child: Text(lead['lead']['name'] ?? '',style: TextStyle(fontSize: 12)),
                                        alignment: Alignment.centerLeft,
                                      ),
                                    )
                                  ),
                                  DataCell(
                                    Container(
                                      width:80,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:MainAxisAlignment.center,
                                        children: [
                                          FadeTransition(
                                            opacity: AlwaysStoppedAnimation(1.0),
                                            child: Text(
                                              lead['lead']['category'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ),
                                  DataCell(
                                    Container(
                                      width:40,
                                      child: Text(lead['lead']['location'] ?? '', style: TextStyle(fontSize: 12),),
                                      alignment: Alignment.centerLeft,
                                    )
                                  ),
                                  DataCell(
                                    Container(
                                      width: 80,
                                      child: Text(lead['lead']['lead_date'] ?? '', style: TextStyle(fontSize: 12),),
                                      alignment: Alignment.centerLeft,
                                    )
                                  ),
                                ]);
                              }).toList(),
                            ),
                          );
                        }
                      ),
                    ),
                  )
                ),
              ],
            )
        )
      ),
    );

  }

}





