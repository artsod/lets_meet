import 'package:flutter/material.dart';

class ContactsManagement extends StatefulWidget {
  @override
  _ContactsManagementState createState() => _ContactsManagementState();
}

class _ContactsManagementState extends State<ContactsManagement> {
  bool _showContacts = true;

  // Dummy data for contacts and groups
  final List<Contact> _contacts = [
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
  ];

  final List<Group> _myPrivateGroups = [
    Group(name: 'Private Group 1'),
    Group(name: 'Private Group 2'),
  ];

  final List<Group> _myPublicGroups = [
    Group(name: 'Public Group 1'),
    Group(name: 'Public Group 2'),
  ];

  final List<Group> _otherPublicGroups = [
    Group(name: 'Public Group 3'),
    Group(name: 'Public Group 4'),
  ];

  Color color = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts and groups'),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showContacts = true;
                    });
                  },
                  child: Container(
                    color: _showContacts ? color : Colors.grey,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Contacts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showContacts = false;
                    });
                  },
                  child: Container(
                    color: !_showContacts ? color : Colors.grey,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Groups',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _showContacts ? _buildContactsList() : _buildGroupsList(),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    List<Contact> installedContacts = _contacts.where((contact) => contact.appInstalled).toList();
    List<Contact> notInstalledContacts = _contacts.where((contact) => !contact.appInstalled).toList();

    return Expanded(
      child: ListView(
        children: [
          _buildContactGroup('People using MeetMeThere', installedContacts),
          _buildContactGroup('Invite to MeetMeThere', notInstalledContacts),
        ],
      ),
    );
  }

  Widget _buildContactGroup(String title, List<Contact> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: contacts.length,
          itemBuilder: (BuildContext context, int index) {
            Contact contact = contacts[index];
            return ListTile(
              leading: const Icon(Icons.account_box_outlined), //##docelowo powinna tutaj być jakaś ikonka usera
              title: Text(
                contact.name,
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: !contact.appInstalled
                  ? ElevatedButton(
                    onPressed: () {
                      // ##Logic to invite contact
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(color),
                    ),
                    child: const Text('Invite'),
              )
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupsList() {
    return Expanded(
      child: ListView(
        children: [
          _buildGroupTypeList('My Private Groups', _myPrivateGroups, true),
          _buildGroupTypeList('My Public Groups', _myPublicGroups, true),
          _buildGroupTypeList('Other Public Groups', _otherPublicGroups, false),
        ],
      ),
    );
  }

  Widget _buildGroupTypeList(String title, List<Group> groups, bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (BuildContext context, int index) {
            Group group = groups[index];
            return ListTile(
              title: Text(
                group.name,
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canEdit)
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Logic to edit group
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Logic to remove group
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupContactsScreen(group: group),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class Contact {
  final String name;
  final bool appInstalled;

  Contact({required this.name, required this.appInstalled});
}

class Group {
  final String name;

  Group({required this.name});
}

class GroupContactsScreen extends StatefulWidget {
  final Group group;

  GroupContactsScreen({required this.group});

  @override
  _GroupContactsScreenState createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  List<Contact> _groupContacts = [
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
  ];

  Color color = Colors.orange.shade700;

  List<Contact> _selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _groupContacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _groupContacts[index];
                bool isSelected = _selectedContacts.contains(contact);
                return ListTile(
                  title: Text(contact.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _removeContact(contact);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedContacts.remove(contact);
                      } else {
                        _selectedContacts.add(contact);
                      }
                    });
                  },
                  tileColor: isSelected ? Colors.grey.shade200 : null,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToAddContacts();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(color),
            ),
            child: const Text('Add people'),
          ),
        ],
      ),
    );
  }

  void _removeContact(Contact contact) {
    setState(() {
      _groupContacts.remove(contact);
      _selectedContacts.remove(contact);
    });
  }

  void _navigateToAddContacts() async {
    List<Contact> selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactsListScreen(),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      setState(() {
        _groupContacts.addAll(selectedContacts);
      });
    }
  }
}

class ContactsListScreen extends StatefulWidget {
  @override
  _ContactsListScreenState createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  List<Contact> _contacts = [
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Mike Johnson', appInstalled: true),
    Contact(name: 'John Doe', appInstalled: true),
    Contact(name: 'Jane Smith', appInstalled: false),
    Contact(name: 'Last one', appInstalled: true),
  ];

  List<Contact> _selectedContacts = [];

  Color color = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts List'),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(), // Set physics to AlwaysScrollableScrollPhysics
              itemCount: _contacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _contacts[index];
                bool isSelected = _selectedContacts.contains(contact);
                return ListTile(
                  title: Text(contact.name),
                  trailing: isSelected ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedContacts.remove(contact);
                      } else {
                        _selectedContacts.add(contact);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _selectedContacts);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(color),
            ),
            child: Text('Add Selected Contacts'),
          ),
        ],
      ),
    );
  }
}