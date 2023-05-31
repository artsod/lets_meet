import 'contact.dart';

class ContactGroup {
    late String id;
    final String name;
    final bool private;
    List <Contact> contacts;
    List<Contact> owners;

    ContactGroup ({required this.id, required this.name, this.contacts= const [], required this.owners, required this.private});
   
    factory ContactGroup.fromJson(Map<String, dynamic> json) {
        final contactsData = json['contacts'] as List<dynamic>;
        final contacts = contactsData.map((data) => Contact.fromJson(data)).toList();

        final ownersData = json['owners'] as List<dynamic>;
        final owners = ownersData.map((data) => Contact.fromJson(data)).toList();
        
 
        return ContactGroup(
            id: json['id'] as String,
            name: json['name'] as String,
            private: json['private'] as bool,
            contacts: contacts,
            owners: owners,
        );
    }
    Map<String, dynamic> serialize () => {
            'id': id,
            'name': name,
            'private': private,
            'contacts': contacts,
            'owners': owners,
    };

  void inviteUser (Contact contact) {
      contacts.add(contact);
  }

  void removeUser (String id) {
//implement removing user safetly.
  }
    
}
