import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skyscape/screens/Feed/feed.dart';
import 'dart:convert';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:skyscape/screens/Search/search.dart';
import 'package:skyscape/screens/Search/users.dart';
import 'package:skyscape/screens/home/sort.dart';
import 'package:skyscape/screens/settings/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/services/database.dart';
import 'dictionaries.dart';
import 'package:skyscape/screens/home/viewdetails.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  Map<String, dynamic?> allValues = {};

  List<String> favouritedLocationNames = []; // default names

  int currentIndex = 0;
  DateTime _selectedDate = DateTime.now();

  bool isLoading = false; // Flag for loading state
  bool _isSortedAlphabetically = true; 

  void getData(String date) async {
    setState(() {
      allValues.clear(); // Clear previous data
      isLoading = true; // Set loading state to true before fetching data
    });

    String url, longitude, latitude, sunSet;
    double sunsetQuality,
        humidityQuality,
        cloudCoverQuality,
        PSI,
        PSIQuality;

    for (var location in favouritedLocationNames) {
      latitude = locationToCoordinatesMapping[location][0].toString();
      longitude = locationToCoordinatesMapping[location][1].toString();

      // Get sunset timing first, the weather conditions will be forecasted based on this timing later on.
      url =
          'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=sunrise,sunset&timezone=Asia%2FSingapore&start_date=${date}&end_date=${date}';
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        sunSet = data["daily"]["sunset"][0].substring(
            11); // Use substring() to exclude the date from the string, only leaving with time

        // Now using the sunset timing, we find the weather conditions
        url =
            'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&hourly=temperature_2m,relative_humidity_2m,cloud_cover&timezone=Asia%2FSingapore&start_hour=${date}T${sunSet}&end_hour=${date}T${sunSet}';
        response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map data = jsonDecode(response.body);
          Map<String, dynamic> currentConditions = data["hourly"];
          allValues[location] = [
            currentConditions["temperature_2m"][0],
            currentConditions["relative_humidity_2m"][0],
            currentConditions["cloud_cover"][0],
            sunSet
          ];
        } else {
          print('Failed to fetch data: ${response.statusCode}');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }

      // ======================== PSI ======================== 
      url = 'https://api.data.gov.sg/v1/environment/psi';
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, dynamic> readings = data['items'][0]['readings'];
        String? region = locationToRegionMapping[location];
        allValues[location].add(readings['psi_twenty_four_hourly'][region]);
        // print(psiValues); ---> {west: 49, east: 61, central: 54, south: 51, north: 38}
        setState(() {});
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
      cloudCoverQuality = allValues[location][2] * 0.4;
      humidityQuality = allValues[location][1] * 0.3;
      PSI = allValues[location][4].toDouble();
      if (PSI <= 55) {
        PSIQuality = 80 + ((55 - PSI) / 55 * 20);
      } else {
        PSIQuality = 20 + ((250 - PSI) / 250 * 80);
      }
      PSIQuality = PSIQuality * 0.3;
      sunsetQuality = cloudCoverQuality + humidityQuality + PSIQuality;
      allValues[location].add(sunsetQuality.toStringAsFixed(1));
    }

    setState(() {
      isLoading = false; // Set loading state to false after fetching data
    });
  }

  String _getCurrentDateInSingapore() {
    DateTime now = DateTime.now().toUtc(); // Getting current time in UTC
    DateTime singaporeTime = now.add(const Duration(
        hours: 8)); // Adding 8 hours to convert to Singapore time
    String formattedDate =
        '${singaporeTime.year}-${_formatDateComponent(singaporeTime.month)}-${_formatDateComponent(singaporeTime.day)}';
    return formattedDate;
  }

  String _formatDateComponent(int component) {
    return component < 10 ? '0$component' : '$component';
  }

  @override
  void initState() {
    super.initState();
    _getFavouritedLocations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getFavouritedLocations();
  }


  Future<void> _sortLocations(int input) async {
    setState(() {
      if (input == 0) { 
        // Sort by quality of sunset
          favouritedLocationNames.sort((a, b) => allValues[b]?[5].compareTo(allValues[a]?[5]));
          _isSortedAlphabetically = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar( duration: Duration(seconds: 1), content: Text('Sorted by Quality of Sunset')),
          );
      } else {
        // Sort by alphabetical order
          favouritedLocationNames.sort();
          _isSortedAlphabetically = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(duration: Duration(seconds: 1), content: Text('Sorted by Alphabetical Order')),
          );
      }
    });

    await DatabaseService(uid: _auth.currentUser!.uid).sortFavouritedLocations(favouritedLocationNames);
  }

  Future<void> _getFavouritedLocations() async {
    List<String> locations = await DatabaseService(uid: _auth.currentUser!.uid)
        .getFavouritedLocations();
    setState(() {
      favouritedLocationNames = locations;
    });
    String currentDate =
        _getCurrentDateInSingapore(); // TODO: Date change according to calendar
    getData(currentDate);
  }

  Future<void> _removeLocation(String location) async {
    await DatabaseService(uid: _auth.currentUser!.uid).removeFavouritedLocation(location);
    setState(() {
      favouritedLocationNames.remove(location);
    });
  }

  @override
  Widget build(BuildContext context) {
      
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange[300]!, Colors.orange[200]!],
            ),
          ),
          child: IndexedStack(
            index: currentIndex,
            children: [
              buildHomeScreen(),
              SearchUsers(),
              FeedPage(),
              ProfileMainWidget(),
            ],
          ),
        ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile',
            ),
          ],
        ),
    );
  }

  

  Widget buildHomeScreen() {
    String _selectedOption = 'Quality';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxisScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                'Saved Locations',
                style: GoogleFonts.lobster(fontSize: 30),
              ),
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 197, 111)!,
              elevation: 0.0,
              leading: PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (String value) {
                setState(() {
                  _selectedOption = value;
                  if (value == 'Quality') {
                    _sortLocations(0);
                  } else if (value == 'Alphabet') {
                    _sortLocations(1);
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Quality',
                  child: Text('Quality'),
                ),
                const PopupMenuItem<String>(
                  value: 'Alphabet',
                  child: Text('Alphabet'),
                ),
              ],
            ),
              actions: <Widget>[
                if (currentIndex == 0)
                  FloatingActionButton.small(
                    child: const Icon(Icons.add, size: 20),
                    shape: CircleBorder(),
                    backgroundColor: Color.fromARGB(220, 252, 249, 242),
                    elevation: 1,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFavouriteLocation()),
                      );
                    },
                  ),
              ],
            )
          ];
        },
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
              TableCalendar(
                calendarFormat: CalendarFormat.week,
                focusedDay: _selectedDate,
                firstDay: DateTime.now().subtract(Duration(days: 365)),
                lastDay: DateTime.now().add(Duration(days: 7)),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                selectedDayPredicate: (DateTime date) {
                  return isSameDay(date, _selectedDate);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDay);
                    getData(selectedDateString);
                  });
                },
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.orange),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: isLoading ? _buildLoadingWidget() : _buildLocationWidgets(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLocationWidgets() {
    return ListView.separated(
      itemCount: favouritedLocationNames.length,
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of the screen width
          child: Divider(
            color: Colors.white.withOpacity(0.5), // Slightly translucent white color
            thickness: 2, // Set the thickness of the divider
          ),
        );
      },
      itemBuilder: (BuildContext context, int index) {
        var location = favouritedLocationNames[index];
        return Dismissible(
          key: Key(location),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) {
            _removeLocation(location);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$location removed'),
              ),
            );
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewDetails(location: location)),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${allValues[location]?[5]}%',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7, right: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        _getSunIconPath(double.parse(allValues[location][5])),
                        width: 140,
                        height: 80,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getSunIconPath(double sunSetQuality) {
    Random random = Random();
    int randomNumber = random.nextInt(4) + 1;

    if (sunSetQuality > 85) {
      return 'assets/good$randomNumber.jpeg';
    } else {
      return 'assets/bad$randomNumber.jpeg';
    }
  }
}