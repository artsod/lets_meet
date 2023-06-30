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

class ApiClient {
  //final String baseUrl;

  ApiClient();

  //General - log on, session, etc.

  Future<bool> isLoggedIn() async {
    // Simulating a delay of 5 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Return false to indicate that the user is not logged in
    return false;
  }

  void sendInvitation(String message, List<String> recipients) async {
    String result = await sendSMS(message: message, recipients: recipients).catchError((onError) {});
  }

  //Contacts

  Future<List<Contact>> getContactsLocal() async {
    List<cs.Contact> csContacts = await cs.ContactsService.getContacts(withThumbnails: true);
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

  Future<List<Contact>> getContacts() async {
    String contents = await rootBundle.loadString('assets/contacts.json');
    final jsonData = json.decode(contents) as List<dynamic>;

    return jsonData.map((json) => Contact.fromJson(json)).toList();
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

  Future<Map<String, dynamic>> fetchGroups() async {
    try {
      final file = File('data.json');
      final response = file.readAsStringSync();
      final  jsonObject= json.decode(response);
      return jsonObject;
    } on FileSystemException catch (e) {
      throw e.message;
    }
    //actual api implemenation
    //final response = await http.get(Uri.parse('$baseUrl/groups'));

    //if (response.statusCode == 200) {

    //final jsonObject = jsonDecode(response.body) as List<dynamic>;
    //return jsonObject;
    //} else {
    //throw Exception('Failed to fetch groups');
    //}
  }

  //Meetings

  Future<List<dynamic>> getCurrentMeetings() async {
    String csv = await rootBundle.loadString('assets/currentMeetings.csv');

    List<dynamic> listOfCurrentMeetings = const CsvToListConverter().convert(
        csv);

    return listOfCurrentMeetings;
  }

  //Places

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