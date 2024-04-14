import 'package:flutter/material.dart';
import 'package:skyscape/screens/Search/followedusers.dart';
import 'package:skyscape/screens/home/home.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  String searchQuery = '';
  final AuthService _auth = AuthService();
  String foundUser = "";
  String targetUserID = "";
  String followingStatus = "";
  bool isLoading = false; // Flag for loading state
  bool showFollowingList = true; // Flag for initial state
  List<String> followingList = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
                style: GoogleFonts.lobster(fontSize: 30),
	              'Search for Users'
              ),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 197, 111)!,
              elevation: 0.0,
      ),
      body: Container(
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
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  if (value == "") {
                    showFollowingList = true;
                    getData();
                  } else {
                    showFollowingList = false;
                    searchUsername(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for a user...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? _buildLoadingWidget()
                  : (showFollowingList
                      ? _buildFollowingListWidget(followingList)
                      : _buildUserWidgets()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFollowingListWidget(List<String> followingList) {
    return ListView.builder(
      itemCount: followingList.length,
      itemBuilder: (context, index) {
        final username = followingList[index];
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .snapshots()
              .map((snapshot) => snapshot.docs.first),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              final profilePicture = userData?['profilePicture'] ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : AssetImage('assets/default_profile.jpg') as ImageProvider,
                ),
                title: Text(username),
                onTap: () {
                  // Navigate to FollowedUser page when a username is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowedUser(username: username),
                    ),
                  );
                },
                trailing: ElevatedButton(
                  onPressed: () {
                    // Handle unfollow action
                    unfollow(username);
                  },
                  child: Text("Unfollow"),
                ),
              );
            } else if (snapshot.hasError) {
              return ListTile(
                leading: CircleAvatar(),
                title: Text(username),
                subtitle: Text('Error loading profile picture'),
              );
            } else {
              return ListTile(
                leading: CircleAvatar(),
                title: Text(username),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserWidgets() {
    if (foundUser == "No user found.") {
      return Center(
        child: Text("No user found."),
      );
    } else {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: foundUser)
            .limit(1)
            .snapshots()
            .map((snapshot) => snapshot.docs.first),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;
            final profilePicture = userData?['profilePicture'] ?? '';
            return Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePicture.isNotEmpty
                          ? NetworkImage(profilePicture)
                          : AssetImage('assets/default_profile.jpg') as ImageProvider,
                    ),
                    title: Text(foundUser),
                    onTap: () {
                      // Navigate to FollowedUser page when the username is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowedUser(username: foundUser),
                        ),
                      );
                    },
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Handle follow/unfollow action
                        if (followingStatus == "following") {
                          unfollow(foundUser);
                        } else if (followingStatus == "not_following") {
                          follow(foundUser);
                        }
                      },
                      child: Text(followingStatus == "not_following" ? "Follow" : "Unfollow"),
                    ),
                  ),
                ],
              ),
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
    }
  }

  void unfollow(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    await DatabaseService(uid: _auth.currentUser!.uid).unfollowUser(username);
    followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();
    followingStatus = "not_following";
    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void follow(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    await DatabaseService(uid: _auth.currentUser!.uid).followUser(username);
    followingStatus = "following";
    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void getData() async {
    followingList.clear();
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  void searchUsername(String username) async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching data
    });

    String user = await DatabaseService(uid: _auth.currentUser!.uid).findUsername(username);
    foundUser = user;

    List<String> followingList = await DatabaseService(uid: _auth.currentUser!.uid).getFollowingList();

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
      if (followingList.contains(username)) {
        followingStatus = "following";
      } else {
        followingStatus = "not_following";
      }
    });
  }
}