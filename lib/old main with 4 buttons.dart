import 'package:flutter/material.dart';
import 'ekranKontakty.dart';
import 'ekranSpotkania.dart';
import 'ekranUstawienia.dart';
import 'map.dart';
import 'lake.dart';
// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranKontakty(),
                  ),
                ),
                child: Text('Zarządzaj kontaktami'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranSpotkania(),
                  ),
                ),
                child: Text('Zarządzaj spotkaniem'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(),
                  ),
                ),
                child: Text('Map'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Lake(),
                  ),
                ),
                child: Text('Lake'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EkranUstawienia(),
                  ),
                ),
                child: Text('Ustawienia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}