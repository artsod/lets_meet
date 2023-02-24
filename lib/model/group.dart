import 'package:flutter/widgets.dart';
import 'user.dart';
import 'package:uuid/uuid.dart';

class ContactGroupModel extends ChangeNotifier {
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
    
}
