import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FavouritePlaces {

  Future<List<List<dynamic>>> getFavouritePlaces() async {

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favouritePlaces.csv');
    String csv = await file.readAsString();

    List<List<dynamic>> favouritePlaces = const CsvToListConverter().convert(csv);

    return favouritePlaces;
  }

  Future<List<List<dynamic>>> removeFromFavourites (String placeID, List<List<dynamic>> favouritePlaces) async {

    favouritePlaces.removeWhere((row) => row[0] == placeID);

    String csv = const ListToCsvConverter().convert(favouritePlaces);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favouritePlaces.csv');

    file.writeAsString(csv);

    return favouritePlaces;
  }

  Future<List<List<dynamic>>> addToFavourites (List<List<dynamic>> favouritePlaces, String placeID, double? lat, double? lng, String title, String? vicinity, String? icon) async {

    favouritePlaces.add([placeID,lat,lng,title,vicinity,icon]);

    String csv = const ListToCsvConverter().convert(favouritePlaces);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favouritePlaces.csv');

    file.writeAsString(csv);

    return favouritePlaces;
  }

}