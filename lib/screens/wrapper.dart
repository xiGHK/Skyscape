import "package:skyscape/screens/home/home.dart";
import "package:flutter/material.dart";
import "package:skyscape/screens/authenticate/authenticate.dart";
import "package:provider/provider.dart";
import 'package:skyscape/models/newuser.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
   // return const Placeholder();
   //return eithr home or authentcate widget
    //return Home();

    Newuser? newuser = Provider.of<Newuser?>(context);
    print("provider statement is executed");
    
    

    if (newuser == null){
      print("newusr is null, authenticating.");
      return const Authenticate();
    } 
    
    else{
      print("newuser is not null, returning home");
      return Home();
    }

  }
}

