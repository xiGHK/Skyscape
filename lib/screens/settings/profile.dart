import 'package:firebase_auth/firebase_auth.dart';
import 'package:skyscape/screens/settings/account.dart';
import 'package:skyscape/screens/settings/bugreport.dart';
import 'package:skyscape/screens/Feed/uploadpicture.dart';
import 'package:skyscape/screens/settings/personalprofile.dart';
import "package:skyscape/services/auth.dart";
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skyscape/screens/Search/users.dart';
 import 'dart:ui' as ui;


class ProfileMainWidget extends StatefulWidget {
  const ProfileMainWidget({super.key});
  
  @override
  State<ProfileMainWidget> createState() => _ProfileMainWidgetState();
}

// Future<String> getUsername() async {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   String? uid = auth.currentUser!.uid;

//   final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
//   final DocumentSnapshot documentSnapshot = await usersCollection.doc(uid).get();
//   if (documentSnapshot.exists) {
//     dynamic data = documentSnapshot.data();
//     String? username = data?.get('username');
//     if(username != null) {
//       return username;
//     } else {
//       return 'Guest';
//     }
//   } else {
//     return "username not found"; // Handle document not found scenario (optional)
//   } 
// } 

class _ProfileMainWidgetState extends State<ProfileMainWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<DocumentSnapshot> _userStream;
  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();
    }
  }

  
  
  @override
  Widget build(BuildContext context) {
  final email = FirebaseAuth.instance.currentUser?.email ?? '';  
  return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final username = userData?['username'] ?? '';
          final profilePicture = userData?['profilePicture'] ?? '';  

    return Scaffold(
      //key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).tertiary,
      appBar: AppBar(
        title: Text(
                style: GoogleFonts.lobster(fontSize: 30),
	              'Profile'
              ),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 197, 111)!,
              elevation: 0.0,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: AlignmentDirectional(0, -1),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 570,
            ),
            decoration: BoxDecoration(
                          gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 255, 197, 111)!,
                        Color.fromARGB(255, 251, 214, 158)!,
                        Color.fromARGB(255, 240, 199, 152)!,
                        Color.fromARGB(255, 246, 186, 122)!,
                      ],
                      stops: [0.1, 0.3, 0.5, 0.8],
                    ),  
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 30),
                    child: Text(
                      'Welcome, ' + '$username',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.pacifico(
                      
                            fontSize: 40,
                              foreground: Paint()
                              ..shader = ui.Gradient.linear(
                              const Offset(0, 100),
                              
                              const Offset(150, 20),
                               <Color>[
                               Color.fromARGB(255, 255, 9, 9),
                               Color.fromARGB(255, 0, 0, 0),
                              ],
                          ),
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalProfile()));
                    },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                          child: Icon(
                            Icons.account_circle,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 60,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20, 0, 0, 0),
                                        child: Text(
                                          'Personal Feed',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 30,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 0, 0),
                                  child: Text(
                                    'View all photos posted',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 12,
                                        ),
                                  ),
                                  
                        
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
                /*Divider(
                  thickness: 1,
                  indent: 0,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),*/
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                   _buildDivider(),
                  SizedBox(height: 25),
                    ]
                )
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Account()));
                    },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                          child: Icon(
                            Icons.settings_outlined,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 60,
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20, 0, 0, 0),
                                        child: Text(
                                          'Account Details',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                fontSize: 30,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20, 0, 0, 0),
                                  child: Text(
                                    'Edit profile picture and account information',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: 12,
                                        ),
                                  ),
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
                /*Divider(
                  thickness: 1,
                  indent: 90,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),*/
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                   _buildDivider(),
                  SizedBox(height: 25),
                    ]
                )
                ),
                //SizedBox(height: 30),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportWidget()));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                            child: Icon(
                              Icons.bug_report_outlined,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 60,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(0, -1),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20, 0, 0, 0),
                                          child: Text(
                                            'Report A Bug',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyLarge
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color:FlutterFlowTheme.of(context)
                                              .primaryText,
                                                  fontSize: 30,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 0, 0),
                                    child: Text(
                                      'Let us know so we can get it fixed',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color:FlutterFlowTheme.of(context)
                                              .primaryText,
                                              fontSize: 12,
                                          ),
                                    ),
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
                /*Divider(
                  thickness: 1,
                  indent: 90,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),*/

                  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                   _buildDivider(),
                  SizedBox(height: 100),
                    ]
                )
                ),
                Align(
                  alignment: AlignmentDirectional(0, -1),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 0),
                    child: FFButtonWidget(
                      onPressed: () async{
                        print("logout button is pressed");
                        await _auth.signOut();
                      },
                      text: 'Log Out',
                      options: FFButtonOptions(
                        width: 90,
                        height: 36,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle: FlutterFlowTheme.of(context).labelMedium,
                        elevation: 0,
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 188, 113, 0)!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }return Center(child: CircularProgressIndicator());
      }
  );
  
}
    Widget _buildDivider() {
    return Container(
      height: 1,
      
      
      color: Color.fromARGB(198, 87, 52, 12),
    );
  }
}
