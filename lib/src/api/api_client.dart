import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart' as cs;
import 'package:flutter_sms/flutter_sms.dart';
import '../model/contact.dart';
import '../model/group.dart';
import '../model/place.dart';
import '../model/meeting.dart';

class ApiClient {
  //final String baseUrl;

  ApiClient();

  //General - log on, session, etc.

  Future<Contact> getCurrentUser(String userID) async {
//##Dodać czytanie numer telefonu - jak robimy, kiedy ktoś się chce zalogować z innego numer?
    String contents = await rootBundle.loadString('assets/contacts.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    final matchingContacts = jsonData.where((contact) => contact['id'] == userID).toList();

    final Contact currentUser = Contact.fromJson(matchingContacts.first);

    return currentUser;

  }


  Future<bool> isLoggedIn() async {
    // Simulating a delay of 5 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Return false to indicate that the user is not logged in
    return false;
  }

  Future<Map<String, String>> getStrings(String language) async {
    String contents = await rootBundle.loadString('assets/strings.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    var languageData = jsonData.where((data) => data['language'] == language).toList();
    var mapOfStringLabels = Map<String, String>.from(languageData[0]);

    return mapOfStringLabels;

  }

  void sendInvitation(String message, List<String> recipients) async {
    String result = await sendSMS(message: message, recipients: recipients).catchError((onError) {});
  }

  //Contacts

  Future<List<Contact>> getContactsLocal() async {
    List<cs.Contact> csContacts = await cs.ContactsService.getContacts(withThumbnails: true);
    print(csContacts.length);
    csContacts.removeWhere((contact) => contact.phones!.isEmpty);
    //##For now for testing
    csContacts.removeWhere((contact) => contact.displayName![0] != ('G') && contact.displayName![0] != ('I') && contact.displayName![0] != ('O')); //##docelowo usunąć - tylko na potrzeby testów, żeby zmniejszyć liczbę kontaktów
    List<Contact> result = csContacts.map((cs.Contact csContact) {
      return Contact.fromJson({
        'id': csContact.phones![0].value,
        'name': csContact.displayName,
        'email': 'marcinmaciejasz@op.pl',
        'phoneNumber': csContact.phones![0].value,
        'isRegistered': true,
      });
    }).toList();
    result[0].isRegistered = false;

    return result;
  }

  void removeFromContacts (List<List<dynamic>> contacts) async {

    String csv = const ListToCsvConverter().convert(contacts);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/contacts.csv');

    file.writeAsString(csv);
  }

  void addToContacts (List<List<dynamic>> contacts) async {

    String csv = const ListToCsvConverter().convert(contacts);

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/contacts.csv');

    file.writeAsString(csv);
  }

  //Groups

  Future<List<Group>> getGroups() async {
    String contents = await rootBundle.loadString('assets/groups.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    return jsonData.map((json) => Group.fromJson(json)).toList();
  }

  void removeGroup () async {

  }

  void addGroup () async {

  }

  void editGroup () async {

  }

  Future<List<GroupContacts>> getGroupContacts() async {
    String contents = await rootBundle.loadString('assets/groupContacts.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    return jsonData.map((json) => GroupContacts.fromJson(json)).toList();
  }

  void removeContactFromGroup () async {

  }

  void addContactToGroup () async {

  }

  //Meetings

  Future<List<Meeting>> getCurrentMeetings() async {
    String contents = await rootBundle.loadString('assets/currentMeetings.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    final List<Meeting> listOfCurrentMeetings = jsonData.map((item) => Meeting.fromJson(item)).toList();

    return listOfCurrentMeetings;
  }

  //Places

  Future<List<CachableGooglePlace>> getFavouritePlaces() async {
    String contents = await rootBundle.loadString('assets/favouritePlaces.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    final List<CachableGooglePlace> places = jsonData.map((item) => CachableGooglePlace.fromJson(item)).toList();

    return places;
  }

  void removeFromFavourites (List<List<dynamic>> favouritePlaces) async {

  }

  void addToFavourites (List<List<dynamic>> favouritePlaces) async {
    //##uwzględnić sprawdzenie czy miejsce jest już w ulubionych
  }

  Future<List<dynamic>> getPlaceTypesForSearch() async {
    String csv = await rootBundle.loadString('assets/placeTypesForSearch.csv');

    List<dynamic> placeTypes = const CsvToListConverter().convert(csv);

    return placeTypes;
  }

//Users

//Future<void> inviteUser(String groupId, String email) async {
//  final response = await http.post(Uri.parse('$baseUrl/groups/$groupId/invite'),
//      body: jsonEncode({'email': email}),
//      headers: {'Content-Type': 'application/json'});

//  if (response.statusCode != 200) {
//    throw Exception('Failed to invite user to group');
//  }
//}
}