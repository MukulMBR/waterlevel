import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:waterlevel/firebase_options.dart';
import 'package:waterlevel/wifi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Level App',
      home: WaterLevelPage(),
    );
  }
}

class WaterLevelPage extends StatefulWidget {
  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  late DatabaseReference _databaseReference;
  double distance = 0.0; // Initialize distance to zero

  void navigateToWifiSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WifiPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _databaseReference =
        FirebaseDatabase.instance.reference().child('/WaterLevel/distance');
    _databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          distance = double.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double tankHeight = 140.0; // Height of the tank in units (e.g., pixels)
    double fillHeight = (distance < 20) ? tankHeight : tankHeight * (1 - (distance / 20.0));
    String waterLevelText =
        (distance < 20) ? 'Full' : '${(distance * 100).toStringAsFixed(2)}%';

    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level App'),
        actions: [
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: navigateToWifiSettingsPage,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Text(waterLevelText,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                wordSpacing: 3,
                color: Colors.white.withOpacity(.7)),
                textScaleFactor: 7),
          ),
          CustomPaint(
            painter: MyPainter(fillHeight / tankHeight), // Pass fill percentage
            child: SizedBox(
              height: size.height,
              width: size.width,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Water Level:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Container(
                  width: 100,
                  height: tankHeight,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100,
                      height: fillHeight,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  waterLevelText,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double fillPercentage;

  MyPainter(this.fillPercentage);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Color(0xff3B6ABA).withOpacity(.8)
      ..style = PaintingStyle.fill;

    var path = Path()
      ..moveTo(0, size.height * (1 - fillPercentage))
      ..lineTo(size.width, size.height * (1 - fillPercentage))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
