import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../model/contact.dart';
import 'dart:convert';
import 'package:contacts_service/contacts_service.dart' as cs;

class ContactsApi {

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
}