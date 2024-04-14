import 'package:skyscape/screens/authenticate/register.dart';
import 'package:flutter/material.dart';
import 'package:skyscape/screens/authenticate/sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  void getData(double longitude, double latitude) async {
  String url = 'https://api.data.gov.sg/v1/environment/rainfall';
  
  http.Response response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map data = jsonDecode(response.body);
    print(data["items"]);
  } else {
    print('Failed to fetch data: ${response.statusCode}');
  }
  }

  void initState(){
    super.initState();
    double longitude = 103.8501;
    double latitude = 1.2897;
    getData(longitude, latitude);
    print("TESTING");
  }

  bool showSignIn = false;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }
  Widget build(BuildContext context) {
    
      
      if (showSignIn){
        return  Register(toggleView: toggleView);
      }
      else {
        return  SignIn(toggleView: toggleView);
      }
    
  }
}