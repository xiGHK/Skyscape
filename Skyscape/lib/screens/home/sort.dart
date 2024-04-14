import 'package:flutter/material.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';


class sortFavouriteLocation extends StatefulWidget {
  final Map<String, dynamic> allValues; 

  const sortFavouriteLocation({Key? key, required this.allValues}) : super(key: key);

  @override
  _sortFavouriteLocationState createState() => _sortFavouriteLocationState();
}

class _sortFavouriteLocationState extends State<sortFavouriteLocation> {
  final AuthService _auth = AuthService();

  Future<void> _sortLocations(int sortOption) async {
    List<String> sortedLocationList;
    if (sortOption == 0) { // Sort by quality
      var sortedEntries = widget.allValues.entries.toList()..sort((a, b) => b.value[5].compareTo(a.value[5]));
      sortedLocationList = sortedEntries.map((entry) => entry.key).toList();
    } else { // Sort by alphabetical order
      var sortedEntries = widget.allValues.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      sortedLocationList = sortedEntries.map((entry) => entry.key).toList();
    }
    await DatabaseService(uid: _auth.currentUser!.uid).sortFavouritedLocations(sortedLocationList);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort Locations'),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      body: SizedBox.expand( // Use SizedBox.expand to expand the Container to full width and height
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange[300]!, Colors.orange[200]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 300, // Set the desired width
                child: ElevatedButton(
                  onPressed: () {
                    _sortLocations(0);
                  },
                  child: Text('Sort by Quality of Sunset'),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300, // Set the desired width
                child: ElevatedButton(
                  onPressed: () {
                    _sortLocations(1);
                  },
                  child: Text('Sort by Alphabetical Order of Locations'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


