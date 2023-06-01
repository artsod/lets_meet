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

  void removeFromFavourites (List<List<dynamic>> favouritePlaces) async {

    String csv = const ListToCsvConverter().convert(favouritePlaces);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favouritePlaces.csv');

    file.writeAsString(csv);
  }

  void addToFavourites (List<List<dynamic>> favouritePlaces) async {

    String csv = const ListToCsvConverter().convert(favouritePlaces);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/favouritePlaces.csv');

    file.writeAsString(csv);
  }
}