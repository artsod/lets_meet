//import 'package:flutter/widgets.dart';
//import 'user.dart';
//import 'package:uuid/uuid.dart';

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

/*class ContactGroupModel extends ChangeNotifier {
    final String id;
    final String name;
    final bool private;
    final List <ApplicationUser> contacts;
    List<ApplicationUser> owners;

    ContactGroupModel ({required this.name, this.contacts= const [], required this.owners, required this.private})
            : id = const Uuid().toString();
   
    ContactGroupModel.deserializeFromJson (Map<String, dynamic> json)
        : id = json['id'],
        name = json['name'],
        private = json['private'],
        contacts = json['contacts'],
        owners = json['owners'];

    Map<String, dynamic> serialize () => {
            'id' : id,
            'name' : name,
            'private' : private,
            'contacts' : contacts,
    };

  void inviteUser (String id) {
      //implement user identification
      notifyListeners();
  }

  void removeUser (String id) {
      //implement user removal

    notifyListeners();
  }
}*/