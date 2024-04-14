import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FollowedUser extends StatefulWidget {
  final String username;

  const FollowedUser({required this.username});

  @override
  _FollowedUserState createState() => _FollowedUserState();
}

class _FollowedUserState extends State<FollowedUser> {
  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<Map<String, dynamic>>> _photosStream;

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.first);

    _photosStream = FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.docs.first.data() as Map<String, dynamic>?;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
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
                    //color: Color.fromARGB(215, 248, 245, 90),
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
                          'Images posted by ${widget.username}',
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