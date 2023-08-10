import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

//##Latitude and longitude from Google Maps can be cached for up to 30 days - we have to address this somehow
//##Google Place ID can be stored indefinitely so we're good here.
//##Own name is user's name so it's ok as well. PlaceID, LatLng and own name is enough for favourites list so that we don't have to call API every time for favourites and we can store them in our database

class CachableGooglePlace {
  final String googlePlaceID;
  final LatLng googlePlaceLatLng;
  final String ownName;
  final String ownIconUrl;

  CachableGooglePlace({
    required this.googlePlaceID,
    required this.googlePlaceLatLng,
    required this.ownName,
    required this.ownIconUrl,
  });

  factory CachableGooglePlace.fromJson(Map<String, dynamic> json) {
    final googlePlaceID = json['googlePlaceID'] as String;
    final latitude = json['googlePlaceLatLng']['latitude'] as double;
    final longitude = json['googlePlaceLatLng']['longitude'] as double;
    final googlePlaceLatLng = LatLng(latitude, longitude);
    final ownName = json['ownName'] as String;
    final ownIconUrl = json['ownIconUrl'] as String;

    return CachableGooglePlace(
      googlePlaceID: googlePlaceID,
      googlePlaceLatLng: googlePlaceLatLng,
      ownName: ownName,
      ownIconUrl: ownIconUrl,
    );
  }
}

class NonCachableGooglePlace {
  final String googlePlaceID;
  final LatLng googlePlaceLatLng;
  final String address;
  final String googleName;
  final String placePhotoReference;
  final String vicinity;

  NonCachableGooglePlace({
    required this.googlePlaceID,
    required this.googlePlaceLatLng,
    required this.address,
    required this.googleName,
    required this.placePhotoReference,
    required this.vicinity,
  });
}