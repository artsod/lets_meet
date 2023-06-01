import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class CurrentMeetings {

  Future<List<dynamic>> getCurrentMeetings() async {
    String csv = await rootBundle.loadString('assets/currentMeetings.csv');

    List<dynamic> listOfCurrentMeetings = const CsvToListConverter().convert(
        csv);

    return listOfCurrentMeetings;
  }
}