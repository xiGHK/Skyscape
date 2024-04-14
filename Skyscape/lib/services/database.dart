import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String username) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'favouritedLocations': [],
      'followingList': [],
      'profilePicture': "",
    });
  }

  // Get user document stream
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }

  Future<void> saveFavouritedLocations(List<String> locations) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();
    
    if (snapshot.exists) {
      // Document exists, update it
      return await documentReference.update({
        'favouritedLocations': locations,
      });
    } else {
      // Document doesn't exist, create it
      return await documentReference.set({
        'favouritedLocations': locations,
      });
    }
  }

  Future<List<String>> getFavouritedLocations() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      List<dynamic> locations = snapshot.get('favouritedLocations');
      return locations.map((location) => location.toString()).toList();
    }
    return [];
  }

  Future<void> sortFavouritedLocations(List<String> locationList) async {
    return await userCollection.doc(uid).update({
      'favouritedLocations': locationList,
    });
  }

  Future<String> findUsernameFromUID(String userid) async {
    DocumentSnapshot snapshot = await userCollection.doc(userid).get();
    if (snapshot.exists) {
      String username = snapshot.get('username');
      return username;
    }
    return "No user found.";
  }

  Future<String> findUIDFromUsername(String username) async {
    QuerySnapshot snapshot = await userCollection.where('username', isEqualTo: username).get();
    if (snapshot.docs.isNotEmpty) {
      String userid = snapshot.docs.first.id;
      return userid;
    }
    return "No user found"; 
  }

  Future<String> findUsername(String username) async {
    try {
      var snapshot = await userCollection.where('username', isEqualTo: username).get();
      
      // Check if any documents were found with the provided username
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['username'];
      } else {
        return "No user found.";
      }
    } catch (e) {
      print('getUsers: Error retrieving user data: $e');
      return "Error retrieving user data.";
    }
  }

  Future<void> followUser(String username) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();
    
    String targetUserID = await findUIDFromUsername(username);

    if (snapshot.exists) {
      // Document exists, update it
      return await documentReference.update({
        'followingList': FieldValue.arrayUnion([targetUserID]),
      });
    } else {
      // Document doesn't exist, create it
      return await documentReference.set({
        'followingList': [targetUserID],
      });
    }
  }

  Future<void> unfollowUser(String username) async {

    String targetUserID = await findUIDFromUsername(username);

    return await userCollection.doc(uid).update({
      'followingList': FieldValue.arrayRemove([targetUserID]),
    });
  }

  Future<List<String>> getFollowingList() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      List<dynamic> following = snapshot.get('followingList');
      List<String> followingUsernames = [];
      
      // Iterate over each targetUserID and get the corresponding username
      for (var targetUserID in following) {
        String username = await findUsernameFromUID(targetUserID.toString());
        if (username != null) {
          followingUsernames.add(username);
        }
      }
      return followingUsernames;
    }
    return [];
  }

  Future<void> removeFavouritedLocation(String location) async {
    return await userCollection.doc(uid).update({
      'favouritedLocations': FieldValue.arrayRemove([location]),
    });
  }

  Future<void> saveFavouritedLocation(String location) async {
    return await userCollection.doc(uid).set({
      'favouritedLocations': FieldValue.arrayUnion([location]),
    }, SetOptions(merge: true));
  }




  Future<void> savePhotoUrl(String photoUrl) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final photoData = {
      'url': photoUrl,
      'timestamp': timestamp,
    };

    return await userCollection.doc(uid).update({
      'photoURLs': FieldValue.arrayUnion([photoData]),
    });
  }

  // Add a method to get the photo data for the current user
  Stream<List<Map<String, dynamic>>> get userPhotos {
    return userCollection.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final photos = data?['photoURLs'] as List<dynamic>? ?? [];
      return photos.cast<Map<String, dynamic>>();
    });
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return {'username': 'Anonymous'}; // Return a default value if the user document doesn't exist
  }

}