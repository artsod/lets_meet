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
import '../widgets/favourites_list.dart';
import '../widgets/search_map_box.dart';
import 'meeting_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late GoogleMapController _mapController;
  final _places = GoogleMapsPlaces(apiKey: 'AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE');
  final Set<Marker> _markers = {};
  final ApiClient _apiClient = ApiClient();
  List<Contact> _contactsList = [];
  late CachableGooglePlace _currentPlace;
  late NonCachableGooglePlace _currentPlaceFull;
  late PlaceDetails _currentPlaceDetails;
  List<CachableGooglePlace> _favouritePlacesList = [];
  String _selectedPlaceType = 'Any';
  String _enteredKeyword = '';
  late CameraPosition _currentCameraPosition;
  final bool _isMeetingInProgress = true; //Do ustawienia dynamicznie
  final Permission _permission = Permission.contacts;
  DateTime _currentBackPressTime = DateTime.now();


  @override
  void initState() {
    super.initState();
    _initializeCameraPosition();
    _requestPermission();
    _initializePersonalData();
  }

  void _initializeCameraPosition() { //##zrobić żeby zaciągało się z lokalizacji albo żeby można było ustawić w ustawieniach
    _currentCameraPosition = const CameraPosition(
      target: LatLng(51.1, 17.0333),
      zoom: 12,
    );
  }

  Future<void> _requestPermission() async {
    final status = await _permission.request();

    setState(() {

    });
  }

  Future<void> _initializePersonalData() async {
    _contactsList = await _apiClient.getContactsLocal();
    _favouritePlacesList = await _apiClient.getFavouritePlaces();
    //## Getting favourite place type should also be here
    setState(() {

    });
  }

  Future<void> _getPhoneContacts() async {
    //_csContacts = await cs.ContactsService.getContacts(withThumbnails: true);
    setState(() {

    });
  }

  void _updateContactsList(List<Contact> updatedList) {
    setState(() {
      _contactsList = updatedList;
    });
  }

  Future<bool> _onWillPop() {
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng location, [double? zoom]) {
    if (zoom != null) {
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(location, zoom));
    } else {
      _mapController.animateCamera(CameraUpdate.newLatLng(location));
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
        ownName: poi.name.replaceAll('\n', ' '),
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

  Future<void> _searchPlaces({required String type, required String keyword}) async {

    // Get the current visible region of the map
    final LatLngBounds visibleRegion = await _mapController.getVisibleRegion();

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
      Fluttertoast.showToast(
          msg: 'No places has been found',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.white,
          textColor: Theme.of(context).colorScheme.primary,
          fontSize: 20,
          gravity: ToastGravity.BOTTOM
      );
      setState(() {
        _markers.clear();
      });
    }
  }

  void _onFavouritePlaceTap (CachableGooglePlace place) {
    _onMapTapped(place.googlePlaceLatLng,17);

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(place.googlePlaceID),
        position: place.googlePlaceLatLng,
        infoWindow: InfoWindow(
          title: place.ownName,
        ),

        onTap: () async {
          _modalOrganizeMeeting(place: place);
        },
      ));
      Navigator.pop(context);
    });
  }

  void _showFavouritePlaces (BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FavouritesList(
            favouritesList: _favouritePlacesList,
            onTap: _onFavouritePlaceTap,
            onRemove: () {
              setState(() {
                _markers.clear();
              });
            }
        );
      },
    );
  }

  void _searchOnTheMap (BuildContext context) async {
    List<String>? input = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SearchMapBox(
          enteredKeyword: _enteredKeyword,
          selectedPlaceType: _selectedPlaceType,
        );
      },
    );

    if (input != null) {
      _enteredKeyword = input[0];
      _selectedPlaceType = input[1];
      _searchPlaces(type: _selectedPlaceType, keyword: _enteredKeyword);
    }
  }

  Future<void> _buildFullCurrentPlace(CachableGooglePlace place) async {
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
                        await _buildFullCurrentPlace(place);
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
                        //##Tutaj powinna być logika dodawania miejsca do ulubionych w back-nedzie
                        //_apiClient.addToFavourites();
                        _favouritePlacesList.add(CachableGooglePlace(
                            googlePlaceID: place.googlePlaceID,
                            googlePlaceLatLng: place.googlePlaceLatLng,
                            ownName: place.ownName,
                            ownIconUrl: 'assets/defaultPlaceIcon.png')
                        );                      },
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

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          100.0, // padding
        ),
      );
    }
  }

  void _showCurrentMeetings() async {
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

  @override
  Widget build(BuildContext context) {

    Widget mapWidget = GoogleMap(
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
        initialCameraPosition: _currentCameraPosition
    );

    Widget hamburgerMenu = Positioned(
      top:50,
      left:20,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {Scaffold.of(context).openDrawer(); },
            );
          },
        ),
      ),
    );

    Widget meetingInProgress = Visibility(
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
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: Row(
            children: [
              const Text('You\'re currently in the meeting', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(
                  Icons.groups,
                  color: Theme.of(context).colorScheme.primary,
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
            ],
          ),
        ),
      ),
    );

    Widget bottomMenu = Positioned(
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
                child: const Text('Your favourite places', style: TextStyle(fontSize: 10), textAlign: TextAlign.center)
            ),
            ElevatedButton(
                onPressed: () {
                  _showCurrentMeetings();
                },
                child: const Text('Find current meetings', style: TextStyle(fontSize: 10), textAlign: TextAlign.center)
            ),
            ElevatedButton(
              onPressed: () {
                _searchPlaces(type: 'point_of_interest', keyword: 'Plac zabaw'); //##This should be taken from the current user
              },
              child: const Text('Search here for: \n Plac zabaw', style: TextStyle(fontSize: 10), textAlign: TextAlign.center), //##$_favouritePlaceType This should be taken from current user
            ),
            ElevatedButton(
                onPressed: () {
                  _searchOnTheMap(context);
                },
                child: const Text('Search on the map', style: TextStyle(fontSize: 10), textAlign: TextAlign.center)
            ),
          ],
        ),
      ),
    );

    Widget drawer = Drawer(
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
                      ContactsManagement(contactList: _contactsList, updateContactsList: _updateContactsList),
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
    );

    return MaterialApp(
      theme: Theme.of(context),
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Stack(
              children: <Widget>[
                mapWidget,
                hamburgerMenu,
                meetingInProgress,
                bottomMenu,
              ]
          ),
          drawer: drawer,
        ),
      ),
    );
  }
}