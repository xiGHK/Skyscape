import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skyscape/screens/loading/loading.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skyscape/screens/Search/followedusers.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowingList();
  }

  Future<void> _fetchFollowingList() async {
    followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> _fetchPhotos() {
    return _databaseService.userCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final photos = data?['photoURLs'] as List<dynamic>? ?? [];
        final username = data?['username'] as String? ?? 'Anonymous';
        final userId = doc.id;
        return photos.map((photo) {
          return {
            'url': photo['url'],
            'username': username,
            'userId': userId,
            'timestamp': photo['timestamp'],
          };
        }).toList();
      }).expand((element) => element).where((photo) {
        return followingList.contains(photo['username']);
      }).toList()
        ..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    });
  }

  void _navigateToFollowedUser(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowedUser(username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                        Color.fromARGB(174, 242, 186, 101)!,
                        Color.fromARGB(154, 251, 214, 158)!,
                        Color.fromARGB(135, 240, 199, 152)!,
                        Color.fromARGB(140, 246, 186, 122)!,
                ],
          stops: [0.1, 0.3, 0.5, 0.8],
        ),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchPhotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final photos = snapshot.data!;
            return 
                 SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
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
                          final userId = photo['userId'];
                          final username = photo['username'];
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                final profilePicture = userData?['profilePicture'] ?? '';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: GestureDetector(
                                        onTap: () => _navigateToFollowedUser(username),
                                        child: CircleAvatar(
                                          backgroundImage: profilePicture.isNotEmpty
                                              ? NetworkImage(profilePicture)
                                              : AssetImage('assets/default_profile.jpg') as ImageProvider,
                                        ),
                                      ),
                                      title: GestureDetector(
                                        onTap: () => _navigateToFollowedUser(username),
                                        child: Text(username),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(photo['url']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error loading user data'),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
             
          } else {
            return const Center(
              child: Text('No data available.'),
            );
          }
        },
      ),
    );
  }
}