import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../model/contact.dart';
import 'dart:convert';

class ContactsApi {

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