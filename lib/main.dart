import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lets_meet/editMeeting.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'organizeMeeting.dart';
import 'package:csv/csv.dart';
import 'dart:async';
import 'package:flutter/services.dart';

// Uncomment lines 3 and 6 to view the visual layout at runtime.
//import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() {
  //debugPaintSizeEnabled = true;
  runApp(const MaterialApp(
    home: MapScreen(),
  ));
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late PlacesDetailsResponse staticPlace; //####To jest tylko na potrzeby statycznego przypisania miejsca. Jak zrobimy właściwe wywołanie spoktania w toku, można to usunąć

  late GoogleMapController mapController;
  final sqrt2 = 1.4142135623730951;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  final bool _isMeetingInProgress = true; //Do ustawienia dynamicznie
  final String _favouritePlaceType = 'Plac zabaw'; //Do ustawienia dynamicznie w opcjach konta
  String selectedPlaceType = 'Any';
  String enteredKeyword = '';
  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(51.1, 17.0333),
    zoom: 12,
  );
  LatLng _tappedLocation = const LatLng(0,0);

  void _onMapTapped(LatLng location) {
    setState(() {
      _tappedLocation = location;
      mapController.animateCamera(CameraUpdate.newLatLng(location));
    });
  }

  num _calculateRadius(LatLngBounds bounds) {
    final topLeftCorner = mt.LatLng(bounds.northeast.latitude,bounds.southwest.longitude);
    final topRightCorner = mt.LatLng(bounds.northeast.latitude,bounds.northeast.longitude);
    final distance = mt.SphericalUtil.computeDistanceBetween(
      topLeftCorner,topRightCorner
    );
    return distance/3;
  }

  Future<void> _getPOI(PointOfInterest poi) async {
    PlacesDetailsResponse response = await _places.getDetailsByPlaceId(poi.placeId);
    late PlaceDetails poiDetails = response.result;
    late Marker marker = Marker(
        markerId: MarkerId(poi.placeId),
        position: poi.position,
        infoWindow: InfoWindow(
            title: poi.name,
            snippet: poiDetails.vicinity,
        ),
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
      _modalOrganizeMeeting(poiDetails);
    });
  }

  Future<void> _getPlaces(String type, String keyword) async {

    late PlacesDetailsResponse placeDetailsResponse;
    late PlaceDetails placeDetails;

    // Get the current visible region of the map
    final LatLngBounds visibleRegion = await mapController.getVisibleRegion();

    // Calculate the radius of the visible region in meters
    final num radius = _calculateRadius(visibleRegion);

    // Search for places of interest near the center of the map
    PlacesSearchResponse response = await _places.searchNearbyWithRadius(
        Location(lat: _currentCameraPosition.target.latitude, lng: _currentCameraPosition.target.longitude),
        radius.toInt(),
        type: type=='Any' ? 'point_of_interest' : type,
        keyword: keyword,
    );
    if (response.status == 'OK') {
      List<PlacesSearchResult> results = response.results;

      // Add markers for each place of interest to the map
      setState(() {
        _markers.clear();
        for (PlacesSearchResult result in results) {
          if (result.geometry?.location != null) {
            _markers.add(Marker(
              markerId: MarkerId(result.placeId),
              position: LatLng(result.geometry!.location.lat, result.geometry!.location.lng),
              infoWindow: InfoWindow(
                title: result.name,
                snippet: result.vicinity,
              ),

              onTap: () async {
                placeDetailsResponse = await _places.getDetailsByPlaceId(result.placeId);
                placeDetails = placeDetailsResponse.result;
                _modalOrganizeMeeting(placeDetails);
              },
            ));
          }
        }
      });
    } else if (response.status =='ZERO_RESULTS') {
      setState(() {
        _markers.clear();
      });
    }
  }

  Future<List<PlaceDetails>> _getFavouritePlaces() async {
    List<PlaceDetails> favouritePlaces=[];
    favouritePlaces.add((await _places.getDetailsByPlaceId('ChIJ-eVnDB7oD0cRTobTaBciLuo')).result);//Na potrzeby testów, docelowo dynamicznie z bazy
    favouritePlaces.add((await _places.getDetailsByPlaceId('ChIJAAAAAAAAAAARU5Q9tt99shs')).result);
    favouritePlaces.add((await _places.getDetailsByPlaceId('ChIJAAAAAAAAAAARKWAQGjU70g4')).result);
    
    return favouritePlaces;
  }

  void _showFavouritePlaces () async {
    List<PlaceDetails> favouritePlaces = await _getFavouritePlaces();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.orange.shade100,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: favouritePlaces.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _onMapTapped(LatLng(favouritePlaces[index].geometry!.location.lat, favouritePlaces[index].geometry!.location.lng));
                    _markers.clear();
                    _markers.add(Marker(
                      markerId: MarkerId(favouritePlaces[index].placeId),
                      position: LatLng(favouritePlaces[index].geometry!.location.lat, favouritePlaces[index].geometry!.location.lng),
                      infoWindow: InfoWindow(
                        title: favouritePlaces[index].name,
                        snippet: favouritePlaces[index].vicinity,
                      ),

                      onTap: () async {
                        _modalOrganizeMeeting(favouritePlaces[index]);
                      },
                    ));
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(favouritePlaces[index].icon!),
                          ),
                          title: Text(favouritePlaces[index].name),
                          subtitle: Text(favouritePlaces[index].vicinity ?? ''),
                        ),
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey),
                          ),
                          onPressed: () {
                            _removeFromFavourites(favouritePlaces[index].placeId);
                          },
                          child: const Text('Remove',
                              style: TextStyle(fontSize: 10))
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 20),
                Expanded(child:
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.orange.shade700),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                        'Back', style: TextStyle(fontSize: 10))
                ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        );
      },
    );
  }

  void _removeFromFavourites (String placeID) {

  }

  void _addToFavourites() {

  }

  void _searchOnTheMap () async {
    final List<String> placeTypes = [//Docelowo do przemyślenia czy ma być na stałe czy dynamicznie i czy dopuszczamy wszystkie z googla
      'Any',
      'cafe',
      'tourist_attraction',
      'restaurant',
      'park',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.orange.shade100,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Keyword',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            enteredKeyword = value;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: enteredKeyword.isEmpty ? 'Enter a keyword' : enteredKeyword,
                            border: const OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 12),
                          textAlignVertical: TextAlignVertical.bottom,
                        ),
                      ),
                    ]),
                ),
              ),
              SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Place type',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPlaceType,
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue != null) {
                                selectedPlaceType = newValue;
                              }
                            });
                          },
                          items: placeTypes.map((placeType) {
                            return DropdownMenuItem<String>(
                              value: placeType,
                              child: Text(
                                placeType,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Select a place type',
                            hintStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(8.0),
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.orange.shade700),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                         _getPlaces(selectedPlaceType, enteredKeyword);
                        },
                        child: const Text('Search for places',
                            style: TextStyle(fontSize: 10))
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                            'Cancel', style: TextStyle(fontSize: 10))
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /* Przykładowa metoda do zapisania do pliku CSV - do wykorzystania później
  void main() {
    List<List<dynamic>> rows = [
      ['Name', 'Age', 'Email'],
      ['John', 25, 'john@example.com'],
      ['Jane', 30, 'jane@example.com'],
      ['Bob', 35, 'bob@example.com'],
    ];

    String csv = const ListToCsvConverter().convert(rows);

    File file = new File('data.csv');
    file.writeAsStringSync(csv);
  }*/

  void _modalOrganizeMeeting (PlaceDetails details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.orange.shade100,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(details.icon!),
              ),
              title: Text(details.name),
              subtitle: Text(details.vicinity ?? ''),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.orange.shade700),
                      ),
                      onPressed: () async =>
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrganizeMeeting(details),
                          ),
                        ),
                      },
                      child: const Text('Let\'s meet here',
                          style: TextStyle(fontSize: 10))
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(child:
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                        'Cancel', style: TextStyle(fontSize: 10))
                ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        );
      },
    );
  }

  void getCurrentMeetings() async {
    String csv = await rootBundle.loadString('assets/currentMeetings.csv');

    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csv);

    _markers.clear();

    for (var row in rowsAsListOfValues) {
      String placeID = row[0];
      double lat = row[1];
      double lng = row[2];
      String name = row[3];
      String vicinity = row[4];

      _markers.add(Marker(
        markerId: MarkerId(placeID),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: name,
          snippet: vicinity,
        ),

        onTap: () async {
          PlacesDetailsResponse placeDetailsResponse = await _places.getDetailsByPlaceId(placeID);
          PlaceDetails placeDetails = placeDetailsResponse.result;
          _modalOrganizeMeeting(placeDetails);
        },
      ));
    }

    setState(() {
      _fitMapToMarkers();
    });
  }

  void _fitMapToMarkers() {
    if (_markers.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _markers.first.position.latitude,
          _markers.first.position.longitude,
        ),
        northeast: LatLng(
          _markers.last.position.latitude,
          _markers.last.position.longitude,
        ),
      );

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          100.0, // padding
        ),
      );
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
                onCameraIdle: () {},
                onTap: _onMapTapped,
                onPoiTap: (PointOfInterest poi) {
                  setState(() {
                    _onMapTapped(poi.position);
                    _getPOI(poi);
                  });
                },
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
                        onPressed: () {Scaffold.of(context).openDrawer(); },
                      ),
                    ),
                  );
                },
              ),
              //Bottom menu
              Builder(
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
                              onPressed: () {
                                _getPlaces('point_of_interest',_favouritePlaceType);
                              },
                              child: Text('Search here for: $_favouritePlaceType', style: const TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {
                                _showFavouritePlaces();
                              },
                              child: const Text('Your favourite places', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {
                                getCurrentMeetings();
                              },
                              child: const Text('Find current meetings', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange.shade700),
                              ),
                              onPressed: () {
                                _searchOnTheMap();
                              },
                              child: const Text('Search on the map', style: TextStyle(fontSize: 10))
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              //Meeting in progress widget
              Builder(
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
                              child: const Text('You\'re currently in the meeting', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                                          EditMeeting(staticPlace.result,true,'You\'re currently in the meeting'),
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
          child: Container(
            color: Colors.orange.shade100,
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
                  title: const Text("Manage contacts"),
                  onTap: () {

                  },
                ),
                ListTile(
                  title: const Text("Settings"),
                  onTap: () {

                  },
                ),
                ListTile(
                  title: const Text("Log out"),
                  onTap: () {

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}