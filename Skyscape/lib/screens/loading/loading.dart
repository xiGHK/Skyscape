import "package:flutter/material.dart";

class Loading extends StatefulWidget {
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void getData() async {
    print("HELLO");
  }

  void initState(){
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  
}