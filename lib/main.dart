import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lets_meet/editMeeting.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'organizeMeeting.dart';
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
  late PlacesDetailsResponse staticPlace; //####To jest tylko na potrzeby statycznego przypisania miejsca. Jak zrobimy właściwe wywołanie spoktania w toku, można to usunąć

  late GoogleMapController mapController;
  final sqrt2 = 1.4142135623730951;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  final bool _isMeetingInProgress = true; //Do ustawienia dynamicznie
  final String _favouritePlaceType = 'Plac zabaw'; //Do ustawienia dynamicznie w opcjach konta

  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(51.1, 17.0333),
    zoom: 12, // Default zoom level
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

  Future<void> _getPlaces() async {

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
        type: "point_of_interest",
        keyword: _favouritePlaceType,
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

              onTap: () async {
                placeDetailsResponse = await _places.getDetailsByPlaceId(result.placeId);
                placeDetails = placeDetailsResponse.result;
                _modalOrganizeMeeting(placeDetails);
              },
            ));
          }
        }
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
                      position: LatLng(favouritePlaces[index].geometry!.location!.lat, favouritePlaces[index].geometry!.location!.lng), // Add non-null assertion operator here
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(favouritePlaces[index].icon!),
                    ),
                    title: Text(favouritePlaces[index].name),
                    subtitle: Text(favouritePlaces[index].vicinity ?? ''),
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
                          Colors.grey),
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
                              onPressed: () {
                                _getPlaces();
                              },
                              child: Text('Search for: $_favouritePlaceType', style: TextStyle(fontSize: 10))
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
                              onPressed: () {},
                              child: const Text('Find meetings nearby', style: TextStyle(fontSize: 10))
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