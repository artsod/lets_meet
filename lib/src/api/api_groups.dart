import 'package:flutter/services.dart';
import 'dart:convert';

class Group {
  String name;
  String type;

  Group({required this.name, required this.type});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}

class GroupContacts {
  final String name;
  final String contactId;

  GroupContacts({required this.name, required this.contactId});

  factory GroupContacts.fromJson(Map<String, dynamic> json) {
    return GroupContacts(
      name: json['name'] as String,
      contactId: json['contactId'] as String,
    );
  }
}

class GroupsApi {

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

}