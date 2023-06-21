import 'package:flutter/material.dart';
import 'package:lets_meet/src/api/api_groups.dart';
import '../model/contact.dart';

class ContactsManagement extends StatefulWidget {
  List<Contact> contactList;
  Function(List<Contact>) updateContactsList;

  ContactsManagement({super.key, required this.contactList, required this.updateContactsList});

  @override
  _ContactsManagementState createState() => _ContactsManagementState();
}

class _ContactsManagementState extends State<ContactsManagement> {
  bool _showContacts = true;

  List<Contact> _contactsList = [];
  late Function(List<Contact>) _updateContactsList;
  GroupsApi groups = GroupsApi();
  List<Group> _groupsList = [];
  Color mainColor = Colors.orange.shade700;

  @override
  void initState() {
    super.initState();
    initializeContacts();
    initializeGroups();
  }

  Future<void> initializeContacts() async {
    _contactsList = widget.contactList;
    _updateContactsList = widget.updateContactsList;

    setState(() {

    });
  }

  Future<void> initializeGroups() async {
    _groupsList = await groups.getGroups();
    setState(() {

    });
  }

  //main structure widget - Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts and groups'),
        backgroundColor: mainColor,
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
                    color: _showContacts ? mainColor : Colors.grey,
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
                    color: !_showContacts ? mainColor : Colors.grey,
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

  //contacts section of main widget - split into two types: registered and unregistered contacts
  Widget _buildContactsList() {
    List<Contact> registeredContacts = _contactsList.where((contact) => contact.isRegisterd).toList();
    List<Contact> unregisteredContacts = _contactsList.where((contact) => !contact.isRegisterd).toList();

    return Expanded(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildContactGroup('People using MeetMeThere', registeredContacts),
          _buildContactGroup('Invite to MeetMeThere', unregisteredContacts),
        ],
      ),
    );
  }

  //widget building each of two contact types (registered and unregistered)
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
            return ListTile(
              leading: const Icon(Icons.account_box_outlined), //##docelowo powinna tutaj być jakaś ikonka usera
              title: Text(
                contacts[index].name,
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: !contacts[index].isRegisterd
                  ? ElevatedButton(
                    onPressed: () {
                      // ##Logic to invite contact
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(mainColor),
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

  //groups section of main widget - split into three types: my private, my public and other public
  Widget _buildGroupsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildGroupTypeList('My Private Groups', _groupsList.where((group) => group.type == 'MyPrivate').toList()),
                _buildGroupTypeList('My Public Groups', _groupsList.where((group) => group.type == 'MyPublic').toList()),
                _buildGroupTypeList('Other Public Groups', _groupsList.where((group) => group.type == 'OtherPublic').toList()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                onPressed: () async {
                  Group? newGroup = await showDialog<Group>(
                    context: context,
                    builder: (BuildContext context) {
                      String groupName = '';
                      String groupType = 'Private';
                      Group newGroup;
                      return StatefulBuilder(
                          builder: (context, setState)
                          {
                            return AlertDialog(
                              title: const Text('Create Group'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        groupName = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Group Name',
                                        floatingLabelStyle: TextStyle(
                                            color: mainColor),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: mainColor))
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        activeColor: mainColor,
                                        value: 'Private',
                                        groupValue: groupType,
                                        onChanged: (value) {
                                          setState(() {
                                            groupType = value!;
                                          });
                                        },
                                      ),
                                      const Text('Private'),
                                      Radio<String>(
                                        activeColor: mainColor,
                                        value: 'Public',
                                        groupValue: groupType,
                                        onChanged: (value) {
                                          setState(() {
                                            groupType = value!;
                                          });
                                        },
                                      ),
                                      const Text('Public'),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text('Create',
                                      style: TextStyle(color: mainColor)),
                                  onPressed: () {
                                    if (groupName.isNotEmpty) {
                                      if (groupType == 'Private') {
                                        newGroup = Group(name: groupName, type: 'MyPrivate');
                                      } else {
                                        newGroup = Group(name: groupName, type: 'MyPublic');
                                      }
                                      Navigator.of(context).pop(newGroup);
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                  if (newGroup != null) {
                    //##Tutaj dodać logikę dodawania grupy w back-endzie
                    groups.addGroup();
                    setState(() {
                      _groupsList.add(newGroup);
                    });
                  }
                },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(mainColor)),
                child: const Text('Create group')
            ),
          ),
        ],
      ),
    );
  }

  //widget building each of three group types
  Widget _buildGroupTypeList(String title, List<Group> group) {
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
        if (group.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'There are no groups here',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: group.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  group[index].name,
                  style: const TextStyle(fontSize: 12.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text('Are you sure you want to remove this group?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Remove',
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    //##Tutaj wstawić logikę usuwania grupy w back-endzie
                                    groups.removeGroup();
                                    setState(() {
                                      _groupsList.removeWhere((element) => element.name == group[index].name);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupContactsScreen(groupList: _groupsList, renameGroup: renameGroup, index: index, contactsList: _contactsList),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  //method for renaming group - passed as callback to other widgets
  void renameGroup(List<Group> updatedList) {
    setState(() {
      _groupsList = updatedList;
    });
  }
}

class GroupContactsScreen extends StatefulWidget {
  List<Group> groupList;
  Function(List<Group>) renameGroup;
  int index;
  List<Contact> contactsList;

  GroupContactsScreen({super.key, required this.groupList, required this.renameGroup, required this.index, required this.contactsList});

  @override
  _GroupContactsScreenState createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  GroupsApi groupContact = GroupsApi();
  List<GroupContacts> _groupContactsMapping = [];
  List<Contact> _groupContactsList = [];
  List<Contact> _contactsList = [];
  Color mainColor = Colors.orange.shade700;

  @override
  void initState() {
    super.initState();
    initializeGroupContacts();
  }

  Future<void> initializeGroupContacts() async {
    _groupContactsMapping = await groupContact.getGroupContacts();
    _groupContactsMapping = _groupContactsMapping.where((contact) => contact.name == widget.groupList[widget.index].name).toList();
    _contactsList = widget.contactsList;
    _groupContactsList = _contactsList.where((contact) => _groupContactsMapping.any((groupContacts) => contact.id == groupContacts.contactId)).toList();
    setState(() {

    });
  }

  Color color = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupList[widget.index].name),
        backgroundColor: color,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              String? input = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  String? userInput;
                  return AlertDialog(
                    title: const Text('Enter new name'),
                    content: TextField(
                      controller: TextEditingController(text: widget.groupList[widget.index].name),
                      decoration: InputDecoration(
                          labelText: 'Group Name',
                          floatingLabelStyle: TextStyle(
                              color: mainColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: mainColor))
                      ),
                      onChanged: (value) {
                        userInput = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Rename',
                            style: TextStyle(color: mainColor)),
                        onPressed: () {
                          Navigator.of(context).pop(userInput);
                        },
                      ),
                    ],
                  );
                },
              );

              if (input != null) {
                // ##Tutaj powinna być logika edycji grupy w backendzie
                groupContact.editGroup();
                widget.groupList[widget.index].name = input;
                widget.renameGroup(widget.groupList);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //If the list is empty, show message
          if (_groupContactsList.isEmpty)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'There are no contacts in this group',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
          //If there are any contacts, show list of them
          Expanded(
            child: ListView.builder(
              itemCount: _groupContactsList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _groupContactsList[index];
                return ListTile(
                  title: Text(contact.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      //##Tutaj wstawić logikę usuwania kontaktu z grupy w back-endzie
                      groupContact.removeContactFromGroup();
                      setState(() {
                        _groupContactsList.remove(contact);
                      });
                    },
                  ),
                  onTap: () {
                    //##Tap on the contact - for now it does nothing. Should it do anything?
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToAddContacts(_groupContactsList);
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

  void _navigateToAddContacts(List<Contact> contactsInGroup) async {
    List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactsListScreen(contactsList: _contactsList, contactsToExclue: contactsInGroup),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      //##Tutaj wstawić logikę dodawania kontaktu do grupy w back-endzie
      groupContact.addContactToGroup();
      setState(() {
        _groupContactsList.addAll(selectedContacts);
      });
    }
  }
}

class AddContactsListScreen extends StatefulWidget {
  final List<Contact> contactsList;
  final List<Contact> contactsToExclue;
  const AddContactsListScreen({super.key, required this.contactsList, required this.contactsToExclue});

  @override
  _AddContactsListScreenState createState() => _AddContactsListScreenState();
}

class _AddContactsListScreenState extends State<AddContactsListScreen> {
  List<Contact> _addableContactsList = [];

  @override
  void initState() {
    super.initState();
    initializeContacts();
  }

  Future<void> initializeContacts() async {
    _addableContactsList = widget.contactsList;
    _addableContactsList = _addableContactsList.where((contact) => contact.isRegisterd).toList();
    _addableContactsList = _addableContactsList.where((newContact) => !widget.contactsToExclue.any((existingContact) => existingContact.id == newContact.id)).toList();
    setState(() {

    });
  }

  final List<Contact> _selectedContacts = [];

  Color color = Colors.orange.shade700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _addableContactsList.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _addableContactsList[index];
                bool isSelected = _selectedContacts.contains(contact);
                return ListTile(
                  title: Text(contact.name),
                  trailing: isSelected ? const Icon(Icons.check) : null,
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
            child: const Text('Add Selected Contacts'),
          ),
        ],
      ),
    );
  }
}