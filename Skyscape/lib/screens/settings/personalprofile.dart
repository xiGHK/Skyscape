import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skyscape/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyscape/flutter_flow_theme.dart';
class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  final AuthService _authService = AuthService();
  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<Map<String, dynamic>>> _photosStream;

  @override
  void initState() {
    super.initState();
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots();

      _photosStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .map((snapshot) {
            final data = snapshot.data() as Map<String, dynamic>?;
            final photos = data?['photoURLs'] as List<dynamic>? ?? [];
            return photos.map((photo) {
              return {
                'url': photo['url'],
                'timestamp': photo['timestamp'],
              };
            }).toList()
              ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Feed', style: GoogleFonts.lobster(fontSize: 30)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber[400],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final profilePicture = userData?['profilePicture'] ?? '';
            final username = userData?['username'] ?? '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                              color: Colors.amber[400],
                              borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(190),
                              bottomRight: Radius.circular(190),
                            ),),
                    height: 200,
                    
                    child: Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: profilePicture.isNotEmpty
                            ? NetworkImage(profilePicture)
                            : AssetImage('assets/default_profile.jpg') as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Images posted',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _photosStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final photos = snapshot.data!;
                              return photos.isNotEmpty
                                  ? GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: photos.length,
                                      itemBuilder: (context, index) {
                                        final photo = photos[index];
                                        final timestamp = photo['timestamp'] as int?;
                                        final formattedTime = timestamp != null
                                            ? DateFormat('yyyy-MM-dd HH:mm').format(
                                                DateTime.fromMillisecondsSinceEpoch(timestamp),
                                              )
                                            : '';
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 300,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(photo['url']),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              formattedTime,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text('No photos available.'),
                                    );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}