import 'package:flutter/material.dart';
import 'package:skyscape/models/newuser.dart';
import 'package:skyscape/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyCAXx9i-CR4HocmI6JVjWIQyEZSktKSQyo",
    //   appId: "1:193819026704:android:662e53c9dc00f464733195",
    //   messagingSenderId: "193819026704",
    //   projectId: "ninja-brew-b1a36",
    // ),
  );

  // temporary code used on 27march 6:55pm
  //await initializeProfilePictureField();
 // await initializeFollowingListField(); USED ON 6:58PM 27 MARarch
  runApp(const MyApp());
}


/*
// Temporary function to init the profilePicture field for existing user accounts
Future<void> initializeProfilePictureField() async {
  final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

  final WriteBatch batch = FirebaseFirestore.instance.batch();

  for (final DocumentSnapshot doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && !data.containsKey('profilePicture')) {
      batch.update(doc.reference, {'profilePicture': ''});
    }
  }

  await batch.commit();
}
*/

/*
Future<void> initializeFollowingListField() async {
  final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

  final WriteBatch batch = FirebaseFirestore.instance.batch();

  for (final DocumentSnapshot doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && !data.containsKey('followingList')) {
      batch.update(doc.reference, {'followingList': []});
    }
  }

  await batch.commit();
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Newuser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
          '/home': (context) => const Home(),
        },
      ),
    );
  }
}