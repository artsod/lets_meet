import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import '../model/place.dart';
import '../screens/meeting_screen.dart';

class BottomPlaceMenu extends StatefulWidget {
  final GoogleMapsPlaces places;
  final CachableGooglePlace place;
  final PlacesSearchResult? searchResult;
  final Map<String,String> labels;

  BottomPlaceMenu({super.key, required this.places, required this.place, required this.labels, this.searchResult});

  @override
  _BottomPlaceMenuState createState() => _BottomPlaceMenuState();
}

class _BottomPlaceMenuState extends State<BottomPlaceMenu> {
  late PlaceDetails _currentPlaceDetails;
  late NonCachableGooglePlace _currentPlaceFull;

  Future<void> _buildFullCurrentPlace() async {
    if (widget.searchResult == null) {
      _currentPlaceDetails = (await widget.places.getDetailsByPlaceId(widget.place.googlePlaceID, fields: ['place_id','name','vicinity','photos','formatted_address'])).result;

      _currentPlaceFull = NonCachableGooglePlace(
          googlePlaceID: widget.place.googlePlaceID,
          googlePlaceLatLng: widget.place.googlePlaceLatLng,
          address: _currentPlaceDetails.formattedAddress ?? '',
          googleName: widget.place.ownName,
          placePhotoReference: _currentPlaceDetails.photos.isNotEmpty ? _currentPlaceDetails.photos[0].photoReference : '',
          vicinity: _currentPlaceDetails.vicinity ?? ''
      );
    } else {
      _currentPlaceFull = NonCachableGooglePlace(
          googlePlaceID: widget.place.googlePlaceID,
          googlePlaceLatLng: widget.place.googlePlaceLatLng,
          address: widget.searchResult!.formattedAddress ?? '',
          googleName: widget.place.ownName,
          placePhotoReference: widget.searchResult!.photos.isNotEmpty ? widget.searchResult!.photos[0].photoReference : '',
          vicinity: widget.searchResult!.vicinity ?? ''
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(widget.place.ownIconUrl),
          ),
          title: Text(widget.place.ownName),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _buildFullCurrentPlace();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MeetingScreen(place: _currentPlaceFull, labels: widget.labels),
                    ),
                  );
                },
                child: Text(
                    widget.labels['letsMeetHere']!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:
              ElevatedButton(
                  onPressed: () async {
                    //##Zamienic to na osobny widget do dodawania do ulubionych    }
                    //##Tutaj powinna być logika dodawania miejsca do ulubionych w back-nedzie
                    //_apiClient.addToFavourites();
/*
                    _favouritePlacesList.add(CachableGooglePlace(
                        googlePlaceID: place.googlePlaceID,
                        googlePlaceLatLng: place.googlePlaceLatLng,
                        ownName: place.ownName,
                        ownIconUrl: 'assets/defaultPlaceIcon.png')
                    );

 */
                  },
                  child: Text(
                      widget.labels['addToFavourites']!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                      widget.labels['cancel']!, style: const TextStyle(fontSize: 10))
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}