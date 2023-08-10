import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:lets_meet/src/model/contact.dart';
import 'package:lets_meet/src/screens/contacts_screen.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import '../api/api_client.dart';
import '../model/place.dart';
import 'meeting_screen.dart';

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

  DateTime _currentBackPressTime = DateTime.now();
  late PlacesDetailsResponse staticPlace; //##To jest tylko na potrzeby statycznego przypisania miejsca. Jak zrobimy właściwe wywołanie spoktania w toku, można to usunąć
  late GoogleMapController mapController;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  final bool _isMeetingInProgress = true; //Do ustawienia dynamicznie
  final String _favouritePlaceType = 'Plac zabaw'; //Do ustawienia dynamicznie w opcjach konta
  List<CachableGooglePlace> favouritePlacesList = [];
  String selectedPlaceType = 'Any';
  String enteredKeyword = '';
  CameraPosition _currentCameraPosition = const CameraPosition( //##do wzięcia z lokalizacji, jeśli użytkownik wyrazi zgodę
    target: LatLng(51.1, 17.0333),
    zoom: 12,
  );
  LatLng _tappedLocation = const LatLng(0,0);
  final Permission _permission = Permission.contacts;
  final ApiClient _apiClient = ApiClient();
  List<Contact> _contactsList = [];
  late CachableGooglePlace _currentPlace;
  late NonCachableGooglePlace _currentPlaceFull;
  late PlaceDetails _currentPlaceDetails;

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
    _currentPlace = CachableGooglePlace(
        googlePlaceID: poi.placeId,
        googlePlaceLatLng: poi.position,
        ownName: poi.name.replaceAll('\n', ''),
        ownIconUrl: 'assets/defaultPlaceIcon.png'
    );
    Marker marker = Marker(
      markerId: MarkerId(_currentPlace.googlePlaceID),
      position: _currentPlace.googlePlaceLatLng,
      infoWindow: InfoWindow(
        title: _currentPlace.ownName,
      ),
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
      _modalOrganizeMeeting(place: _currentPlace);
    });
  }

  Future<void> _searchPlaces(String type, String keyword) async {

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
                _currentPlace = CachableGooglePlace(
                    googlePlaceID: result.placeId,
                    googlePlaceLatLng: LatLng(result.geometry!.location.lat,result.geometry!.location.lng),
                    ownName: result.name,
                    ownIconUrl: 'assets/defaultPlaceIcon.png'
                );
                _modalOrganizeMeeting(place: _currentPlace, searchResults: result);
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
                    _onMapTapped(favouritePlacesList[index].googlePlaceLatLng,17);

                    setState(() {
                      _markers.clear();
                      _markers.add(Marker(
                        markerId: MarkerId(favouritePlacesList[index].googlePlaceID),
                        position: favouritePlacesList[index].googlePlaceLatLng,
                        infoWindow: InfoWindow(
                          title: favouritePlacesList[index].ownName,
                        ),

                        onTap: () async {
                          _modalOrganizeMeeting(place: favouritePlacesList[index]);
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
                            backgroundImage: AssetImage(favouritePlacesList[index].ownIconUrl),
                          ),
                          title: Text(favouritePlacesList[index].ownName),
                        ),
                      ),
                      ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                          onPressed: () {
                            setState(() {
                              removeFromFavourites(favouritePlacesList[index].googlePlaceID);
                              _markers.clear();
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
    //##Tutaj powinna być logika usuwania miejsca z ulubionych w back-nedzie
    //_apiClient.removeFromFavourites();
    favouritePlacesList.removeWhere((row) => row.googlePlaceID == placeID);
  }

  void addToFavourites (CachableGooglePlace place) async {
    //##Tutaj powinna być logika dodawania miejsca do ulubionych w back-nedzie
    //_apiClient.addToFavourites();
    favouritePlacesList.add(CachableGooglePlace(
        googlePlaceID: place.googlePlaceID,
        googlePlaceLatLng: place.googlePlaceLatLng,
        ownName: place.ownName,
        ownIconUrl: 'assets/defaultPlaceIcon.png')
    );
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
                          _searchPlaces(selectedPlaceType, enteredKeyword);
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

  Future<void> buildFullCurrentPlace(CachableGooglePlace place) async {
    _currentPlaceDetails = (await _places.getDetailsByPlaceId(place.googlePlaceID, fields: ['place_id','name','vicinity','photos','formatted_address'])).result;

    _currentPlaceFull = NonCachableGooglePlace(
        googlePlaceID: place.googlePlaceID,
        googlePlaceLatLng: place.googlePlaceLatLng,
        address: _currentPlaceDetails.formattedAddress ?? '',
        googleName: place.ownName,
        placePhotoReference: _currentPlaceDetails.photos.isNotEmpty ? _currentPlaceDetails.photos[0].photoReference : '',
        vicinity: _currentPlaceDetails.vicinity ?? ''
    );
  }

  void _modalOrganizeMeeting ({required CachableGooglePlace place, PlacesSearchResult? searchResults}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(place.ownIconUrl),
              ),
              title: Text(place.ownName),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (searchResults == null) {
                        await buildFullCurrentPlace(place);
                      } else {
                        _currentPlaceFull = NonCachableGooglePlace(
                            googlePlaceID: place.googlePlaceID,
                            googlePlaceLatLng: place.googlePlaceLatLng,
                            address: searchResults.formattedAddress ?? '',
                            googleName: place.ownName,
                            placePhotoReference: searchResults.photos.isNotEmpty ? searchResults.photos[0].photoReference : '',
                            vicinity: searchResults.vicinity ?? ''
                        );
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MeetingScreen(place: _currentPlaceFull, contactsList: _contactsList),
                        ),
                      );
                    },
                    child: const Text('Let\'s meet here', style: TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child:
                  ElevatedButton(
                      onPressed: () async {
                        addToFavourites(place);
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
          //_modalOrganizeMeeting(placeDetails);
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

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(_currentBackPressTime) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press back again to exit app',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.white,
        textColor: Theme.of(context).colorScheme.primary,
        fontSize: 20,
        gravity: ToastGravity.BOTTOM
      );
      return Future.value(false);
    }
    Fluttertoast.cancel();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: WillPopScope (
        onWillPop: onWillPop,
        child: Scaffold(
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
                                  _searchPlaces('point_of_interest',_favouritePlaceType);
                                },
                                child: Text('Search here for: $_favouritePlaceType', style: const TextStyle(fontSize: 10))
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MeetingScreen(place: _currentPlaceFull, contactsList: _contactsList),
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