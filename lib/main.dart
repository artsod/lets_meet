import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ekranKontakty.dart';
import 'ekranSpotkania.dart';
import 'ekranUstawienia.dart';
// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(51.1, 17.0333);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
            Builder(
              builder: (BuildContext context) {
                return Positioned(
                  top:50,
                  left:20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      onPressed: () { Scaffold.of(context).openDrawer(); },
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    ),
                  ),
                );
              },
            ),          ]
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green[700],
                ),
                child: const Text("Hi Marcin"),
              ),
              ListTile(
                title: const Text("Create meeting"),
                onTap: () {
                // handle item 1 press
                },
              ),
              ListTile(
                title: const Text("Join meeting"),
                onTap: () {
                // handle item 2 press
                },
              ),
              ListTile(
                title: const Text("Manage contacts"),
                onTap: () {
                  // handle item 2 press
                },
              ),
              ListTile(
                title: const Text("Settings"),
                onTap: () {
                  // handle item 2 press
                },
              ),
              ListTile(
                title: const Text("Log out"),
                onTap: () {
                  // handle item 2 press
                },
              ),
            ],
          ),
        )
      ),
    );
  }
}