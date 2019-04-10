import 'package:emsakia/CircularListItem.dart';
import 'package:emsakia/Models/CircularItem.dart';
import 'package:flutter/material.dart';
import 'package:emsakia/Models/APIResponse.dart';
import 'package:http/http.dart' as http;
import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart' as wheel;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emsakia Ramdan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  wheel.FixedExtentScrollController _controller;
  bool notifications = true;
  var width = 0.0;
  final MaterialColor primaryColorShades = MaterialColor(
    0xFF38003C,
    <int, Color>{
      50: Color(0xFF38003C),
      100: Color(0xFF38003C),
      200: Color(0xFF38003C),
      300: Color(0xFF38003C),
      400: Color(0xFF38003C),
      500: Color(0xFF38003C),
      600: Color(0xFF38003C),
      700: Color(0xFF38003C),
      800: Color(0xFF38003C),
      900: Color(0xFF38003C),
    },
  );

  List<CircularItem> listItems = [
    new CircularItem("Quran", 'img/ramdan_cover5.jpg'),
    new CircularItem("Azkar", 'img/ramdan_cover5.jpg'),
    new CircularItem("Ad3ya", 'img/ramdan_cover5.jpg'),
    new CircularItem("Seb7a", 'img/ramdan_cover5.jpg'),
    new CircularItem("A7adeeth", 'img/ramdan_cover5.jpg'),
  ];

  _listListener() {
    setState(() {});
  }

  Future<APIResponse> results;

  @override
  void initState() {
    super.initState();
    results = getPrayers();
    _controller = wheel.FixedExtentScrollController();
    _controller.addListener(_listListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Color.fromRGBO(25, 117, 25, 1),
      backgroundColor: primaryColorShades,
      body: Stack(
        children: <Widget>[
          _buildBody(context),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return wheel.CircleListScrollView.useDelegate(
      itemExtent: 120,
      physics: wheel.CircleFixedExtentScrollPhysics(),
      controller: _controller,
      axis: Axis.vertical,
      radius: MediaQuery.of(context).size.width * 0.8,
      childDelegate: wheel.CircleListChildBuilderDelegate(
        builder: (context, index) {
          int currentIndex = 0;
          try {
            currentIndex = _controller.selectedItem;
          } catch (_) {}
          final resizeFactor =
              (1 - (((currentIndex - index).abs() * 0.3).clamp(0.0, 1.0)));
          return FlatButton(
              onPressed: () => debugPrint("Pressed"),
              child: CircleListItem(
                resizeFactor: resizeFactor,
                item: listItems[index],
              ));
        },
        childCount: listItems.length,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: SingleChildScrollView(
          child: Container(
        child: Column(
          children: <Widget>[
            _buildBackdrop(context),
            _buildPrayerTimes(),
          ],
        ),
      )),
    );
  }

  Widget _buildBackdrop(BuildContext context) {
    return Container(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        width = constraints.biggest.width;
        return Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipPath(
                    clipper: Mclipper(),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0.0, 10.0),
                                blurRadius: 10.0)
                          ]),
                      child: Container(
                        width: width,
                        height: width,
                        child: Image.asset(
                          "img/ramdan_cover5.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        showIftarImsakTime("الامساك"),
                        Expanded(
                          child: Container(),
                        ),
                        showIftarImsakTime("الافطار"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            notificationAlert(),
          ],
        );
      }),
    );
  }

  Widget _buildPrayerTimes() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 300.0,
          child: FutureBuilder<APIResponse>(
            future: results,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return buildSchedule(snapshot.data);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }

  Widget buildSchedule(APIResponse response) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text("Fajr",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(_getTransformedTime(response.data[0].timings.fajr),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("Duhr",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(_getTransformedTime(response.data[0].timings.dhuhr),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("Asr",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(_getTransformedTime(response.data[0].timings.asr),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("Maghrib",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(_getTransformedTime(response.data[0].timings.maghrib),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("Isha",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: Text(_getTransformedTime(response.data[0].timings.isha),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget showIftarImsakTime(String which) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Text(
              which,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: FutureBuilder<APIResponse>(
              future: results,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String iftar = _getTransformedTime(
                      snapshot.data.data[0].timings.maghrib);
                  String imsak =
                      _getTransformedTime(snapshot.data.data[0].timings.imsak);
                  return Text(
                    which == "الامساك" ? imsak : iftar,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  );
                } else if (snapshot.hasError) {
                  return Text("No Internet");
                }
                // By default, show a loading spinner
                return CircularProgressIndicator();
              },
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.yellowAccent, width: 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationAlert() {
    return Positioned(
      right: width / 2 - 25,
      top: width,
      child: FractionalTranslation(
        translation: Offset(0.0, -0.5),
        child: FloatingActionButton(
          onPressed: () {
            notifications = !notifications;
            setState(() {});
          },
          backgroundColor: Colors.white,
          child: Icon(
            notifications
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: notifications ? Colors.green : Colors.grey,
            size: 40,
          ),
        ),
      ),
    );
  }

  Future<APIResponse> getPrayers() async {
    final response = await http.get(
        'http://api.aladhan.com/v1/hijriCalendarByCity?city=cairo&country=Egypt&method=5&month=09&year=1440');
    if (response.statusCode == 200) {
      return APIResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Check Your Internet Connection");
    }
  }

  String _getTransformedTime(String unFormattedTime) {
    RegExp exp = new RegExp(r"(\d{2}:\d{2})\s+");
    Match match = exp.firstMatch(unFormattedTime);

    return match.group(0);
  }
}

class Mclipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 40.0);

    var controlPoint = Offset(size.width / 4, size.height);
    var endpoint = Offset(size.width / 2, size.height);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endpoint.dx, endpoint.dy);

    var controlPoint2 = Offset(size.width * 3 / 4, size.height);
    var endpoint2 = Offset(size.width, size.height - 40.0);

    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endpoint2.dx, endpoint2.dy);

    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}