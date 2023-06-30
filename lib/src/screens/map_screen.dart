import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lets_meet/src/model/contact.dart';
import 'package:lets_meet/src/screens/edit_meeting_screen.dart';
import 'package:lets_meet/src/screens/contacts_screen.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../api/api_client.dart';
import 'organize_meeting_screen.dart';

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
  late PlacesDetailsResponse staticPlace; //##To jest tylko na potrzeby statycznego przypisania miejsca. Jak zrobimy właściwe wywołanie spoktania w toku, można to usunąć
  late GoogleMapController mapController;
  final sqrt2 = 1.4142135623730951;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  final bool _isMeetingInProgress = true; //Do ustawienia dynamicznie
  final String _favouritePlaceType = 'Plac zabaw'; //Do ustawienia dynamicznie w opcjach konta
  List<List<dynamic>> favouritePlacesList = [];
  String selectedPlaceType = 'Any';
  String enteredKeyword = '';
  CameraPosition _currentCameraPosition = const CameraPosition(
    target: LatLng(51.1, 17.0333),
    zoom: 12,
  );
  LatLng _tappedLocation = const LatLng(0,0);
  final Permission _permission = Permission.contacts;
  final ApiClient _apiClient = ApiClient();
  List<Contact> _contactsList = [];

  @override
  void initState() {
    super.initState();
    initializeContacts();
  }

  Future<void> requestPermission() async {
    final status = await _permission.request();

    setState(() {

    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng location, [double? zoom]) {
    _tappedLocation = location;
    if (zoom != null) {
      mapController.animateCamera(CameraUpdate.newLatLngZoom(location, zoom));
    } else {
      mapController.animateCamera(CameraUpdate.newLatLng(location));
    }
    setState(() {

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

  void _showFavouritePlaces (BuildContext context) async {
    favouritePlacesList = await _apiClient.getFavouritePlaces();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: favouritePlacesList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _onMapTapped(LatLng(favouritePlacesList[index][1],favouritePlacesList[index][2]),17);

                    setState(() {
                      _markers.clear();
                      _markers.add(Marker(
                        markerId: MarkerId(favouritePlacesList[index][0]),
                        position: LatLng(favouritePlacesList[index][1],favouritePlacesList[index][2]),
                        infoWindow: InfoWindow(
                          title: favouritePlacesList[index][3],
                          snippet: favouritePlacesList[index][4],
                        ),

                        onTap: () async {
                          _modalOrganizeMeeting((await _places.getDetailsByPlaceId(favouritePlacesList[index][0])).result);
                        },
                      ));
                      Navigator.pop(context);
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(favouritePlacesList[index][5]),
                          ),
                          title: Text(favouritePlacesList[index][3]),
                          subtitle: Text(favouritePlacesList[index][4] ?? ''),
                        ),
                      ),
                      ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                          onPressed: () {
                            setState(() {
                              removeFromFavourites(favouritePlacesList[index][0]);
                              _markers.clear();
                              Navigator.pop(context);
                              _showFavouritePlaces(context);
                            });
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
                Expanded(
                  child:
                  ElevatedButton(
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

  void removeFromFavourites(String placeID) {
    favouritePlacesList.removeWhere((row) => row[0] == placeID);
    _apiClient.removeFromFavourites(favouritePlacesList);
  }

  void addToFavourites (String placeID, double? lat, double? lng, String title, String? vicinity, String? icon) async {
    favouritePlacesList.add([placeID,lat,lng,title,vicinity,icon]);
    _apiClient.addToFavourites(favouritePlacesList);
  }

  void _searchOnTheMap (BuildContext context) async {
    final List<String> placeTypes = [//##Docelowo do przemyślenia czy ma być na stałe czy dynamicznie i czy dopuszczamy wszystkie z googla
      'Any',
      'cafe',
      'tourist_attraction',
      'restaurant',
      'park',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
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

  void _modalOrganizeMeeting (PlaceDetails details) {
    showModalBottomSheet(
      context: context,
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
                    onPressed: () async =>
                    {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrganizeMeeting(place: details, contactsList: _contactsList),
                        ),
                      ),
                    },
                    child: const Text('Let\'s meet here', style: TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child:
                  ElevatedButton(
                      onPressed: () async {
                        addToFavourites(details.placeId, details.geometry?.location.lat, details.geometry?.location.lng, details.name, details.vicinity, details.icon);
                      },
                      child: const Text(
                          'Add to favourites', style: TextStyle(fontSize: 10))
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child:
                  ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
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

  void showCurrentMeetings() async {
    List<dynamic> listOfCurrentMeetings = await _apiClient.getCurrentMeetings();

    _markers.clear();

    for (var row in listOfCurrentMeetings) {
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
          PlaceDetails placeDetails = (await _places.getDetailsByPlaceId(placeID)).result;
          _modalOrganizeMeeting(placeDetails);
        },
      ));
    }
    setState(() {
      _fitMapToMarkers();
    });
  }

  Future<void> initializeContacts() async {
    _contactsList = await _apiClient.getContactsLocal();
    setState(() {

    });
  }

  Future<void> getPhoneContacts() async {
    //_csContacts = await cs.ContactsService.getContacts(withThumbnails: true);

    setState(() {

    });
  }

  void updateContactsList(List<Contact> updatedList) {
    setState(() {
      _contactsList = updatedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: Scaffold(
        body: Stack(
            children: <Widget>[
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
                        color: Theme.of(context).colorScheme.primary,
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
                        color: Theme.of(context).colorScheme.secondary,
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
                              onPressed: () {
                                _getPlaces('point_of_interest',_favouritePlaceType);
                              },
                              child: Text('Search here for: $_favouritePlaceType', style: const TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _showFavouritePlaces(context);
                              },
                              child: const Text('Your favourite places', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              onPressed: () {
                                showCurrentMeetings();
                              },
                              child: const Text('Find current meetings', style: TextStyle(fontSize: 10))
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _searchOnTheMap(context);
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
                          color: Theme.of(context).colorScheme.secondary,
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
                                color: Theme.of(context).colorScheme.primary,
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text("Hi Marcin"),
                ),
                ListTile(
                  title: const Text("Contacts and groups"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContactsManagement(contactList: _contactsList, updateContactsList: updateContactsList),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("My meetings"),
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