import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lets_meet/groups_screen.dart';
import 'package:lets_meet/meetingInProgress.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'organizeMeeting.dart';
import 'package:provider/provider.dart';
import 'model/groups_list_model.dart';
import 'groups_list.dart';

// Uncomment lines 3 and 6 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
    // debugPaintSizeEnabled = true;
    runApp(
        ChangeNotifierProvider(
            create: (context) => GroupsListModel(),
            child: MaterialApp(
                home: MapScreen(),
            )
        )
    );
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late PlacesDetailsResponse staticPlace; //####To jest tylko na potrzeby statycznego przypisania miejsca. Jak zrobimy właściwe wywołanie spoktania w toku, można to usunąć

  late GoogleMapController mapController;

  final sqrt2 = 1.4142135623730951;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  bool _isMeetingInProgress = true; //Do ustawienia dynamicznie

  CameraPosition _currentCameraPosition = CameraPosition(
    target: LatLng(51.1, 17.0333),
    zoom: 12, // Default zoom level
  );

  LatLng _tappedLocation = LatLng(0,0);

  void _onMapTapped(LatLng location) {
    setState(() {
      _tappedLocation = location;
      mapController.animateCamera(CameraUpdate.newLatLng(location));
    });
  }

  num calculateRadius(LatLngBounds bounds) {
    final topLeftCorner = mt.LatLng(bounds.northeast.latitude,bounds.southwest.longitude);
    final topRightCorner = mt.LatLng(bounds.northeast.latitude,bounds.northeast.longitude);
    final distance = mt.SphericalUtil.computeDistanceBetween(
      topLeftCorner,topRightCorner
    );
    return distance/3;
  }

  Future<void> _getPlaces() async {

    late PlacesDetailsResponse placeDetails;

    // Get the current visible region of the map
    final LatLngBounds visibleRegion = await mapController.getVisibleRegion();

    // Calculate the radius of the visible region in meters
    final num radius = calculateRadius(visibleRegion);

    // Search for places of interest near the center of the map
    PlacesSearchResponse response = await _places.searchNearbyWithRadius(
      Location(lat: _currentCameraPosition.target.latitude, lng: _currentCameraPosition.target.longitude),
      radius.toInt(),
      type: "point_of_interest"
    );

    if (response.status == 'OK') {
      List<PlacesSearchResult> results = response.results;

      // Add markers for each place of interest to the map
      setState(() {
        _markers.clear();
        for (PlacesSearchResult result in results) {
          if (result.geometry?.location != null) { // Add null check for geometry and location
            _markers.add(Marker(
              markerId: MarkerId(result.placeId),
              position: LatLng(result.geometry!.location!.lat, result.geometry!.location!.lng), // Add non-null assertion operator here
              infoWindow: InfoWindow(
                title: result.name,
                snippet: result.vicinity,
              ),

              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.orange.shade100,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,

                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(result.icon!),
                          ),
                          title: Text(result.name),
                          subtitle: Text(result.vicinity ?? ''),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                                ),
                                onPressed: () async => {
                                  placeDetails = await _places.getDetailsByPlaceId(result.placeId),
                                  if (response.status == 'OK') {
                                    print('--------------'),
                                    print(placeDetails.result.placeId),
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrganizeMeeting(placeDetails.result),
                                      ),
                                    ),
                                  }
                                },
                                child: const Text('Let\'s meet here', style: TextStyle(fontSize: 10))
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child:
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                                ),
                                onPressed: () {Navigator.pop(context);},
                                child: const Text('Cancel', style: TextStyle(fontSize: 10))
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ));
          }
        }
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
            children: <Widget>[
              //GoogleMap
              GoogleMap(
                onMapCreated: _onMapCreated,
                markers: _markers,
                onCameraMove: (CameraPosition position) {
                  _currentCameraPosition = position;
                },
                onCameraIdle: () {
                  setState(() {
                    _getPlaces();
                  });
                },
                onTap: _onMapTapped,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _currentCameraPosition.target,
                  zoom: 11.0,
                ),
              ),
              //Hamburger menu
              Builder(
                builder: (BuildContext context) {
                  return Positioned(
                    top:50,
                    left:20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () { Scaffold.of(context).openDrawer(); },
                      ),
                    ),
                  );
                },
              ),
              //Bottom menu
              Builder( //Create bottom menu widget
                builder: (BuildContext context) {
                  return Positioned(
                    left:30,
                    right:30,
                    bottom: 20,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(10),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: 4.7,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {},
                              child: const Text('Find meetings nearby', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {},
                              child: const Text('Find popular places nearby', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {},
                              child: const Text('Search for playgrounds', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {},
                              child: const Text('Search on the map', style: TextStyle(fontSize: 10))
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              //Meeting in progress widget
              Builder( //Create meeting in progress widget
                builder: (BuildContext context) {
                  return Visibility(
                    visible: _isMeetingInProgress,
                    child: Positioned(
                      bottom: 130,
                      right:35,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              child: Text('You\'re currently in the meeting', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                            decoration: BoxDecoration(
                                color: Colors.orange.shade700,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.access_time_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () async => {
                                  staticPlace=await _places.getDetailsByPlaceId('ChIJ-eVnDB7oD0cRTobTaBciLuo'), //Do usunięcia po wlaściwej implementacji tego wywołania ze spotkaniem w toku
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MeetingInProgress(staticPlace.result),
                                    ),
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                  return GroupsScreen();
                              }
                          )
                      );
                  }
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
