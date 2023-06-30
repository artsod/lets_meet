import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../model/contact.dart';
import '../model/group.dart';

class ContactsManagement extends StatefulWidget {
  final List<Contact> contactList;
  final Function(List<Contact>) updateContactsList;

  const ContactsManagement({super.key, required this.contactList, required this.updateContactsList});

  @override
  _ContactsManagementState createState() => _ContactsManagementState();
}

class _ContactsManagementState extends State<ContactsManagement> {
  bool _showContacts = true;

  List<Contact> _contactsList = [];
  late Function(List<Contact>) _updateContactsList;
  final ApiClient _apiClient = ApiClient();
  List<Group> _groupsList = [];

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
    _groupsList = await _apiClient.getGroups();
    setState(() {

    });
  }

  //main structure widget - Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts and groups'),
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
                    color: _showContacts ? Theme.of(context).colorScheme.primary : Colors.grey,
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
                    color: !_showContacts ? Theme.of(context).colorScheme.primary : Colors.grey,
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
    List<Contact> registeredContacts = _contactsList.where((contact) => contact.isRegistered).toList();
    List<Contact> unregisteredContacts = _contactsList.where((contact) => !contact.isRegistered).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildContactGroup('People using MeetMeThere', registeredContacts),
                _buildContactGroup('Invite to MeetMeThere', unregisteredContacts),
              ],
            ),
          ),
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
              leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(contacts[index].name[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
              ),
              //leading: const Icon(Icons.account_box_outlined), //##docelowo powinna tutaj być jakaś ikonka usera
              title: Text(
                contacts[index].name,
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!contacts[index].isRegistered)
                    IconButton(
                      icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text('This action will create an invitation text message ready to be sent. Do you want to continue?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Continue'),
                                  onPressed: () {
                                    //##Tutaj wstawić logikę wysyłania zaproszenia w back-endzie
                                    _apiClient.sendInvitation('Hi! Check out MeetMeThere app where you can easily notify your friends where they can meet you. Here\'s the link: TUTAJ LINK', [contacts[index].phoneNumber]);
                                    setState(() {

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
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text('Are you sure you want to remove this contact?'),
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
                                  //##Tutaj wstawić logikę usuwania kontaktu w back-endzie
                                  //groups.removeGroup();
                                  setState(() {
                                    _contactsList.removeWhere((element) => element.phoneNumber == contacts[index].phoneNumber);
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
                                    decoration: const InputDecoration(labelText: 'Group Name'),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Radio<String>(
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
                                  child: const Text('Create'),
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
                    _apiClient.addGroup();
                    setState(() {
                      _groupsList.add(newGroup);
                    });
                  }
                },
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
                                    _apiClient.removeGroup();
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
  final List<Group> groupList;
  final Function(List<Group>) renameGroup;
  final int index;
  final List<Contact> contactsList;

  const GroupContactsScreen({super.key, required this.groupList, required this.renameGroup, required this.index, required this.contactsList});

  @override
  _GroupContactsScreenState createState() => _GroupContactsScreenState();
}

class _GroupContactsScreenState extends State<GroupContactsScreen> {
  final ApiClient _apiClient = ApiClient();
  List<GroupContacts> _groupContactsMapping = [];
  List<Contact> _groupContactsList = [];
  List<Contact> _contactsList = [];

  @override
  void initState() {
    super.initState();
    initializeGroupContacts();
  }

  Future<void> initializeGroupContacts() async {
    _groupContactsMapping = await _apiClient.getGroupContacts();
    _groupContactsMapping = _groupContactsMapping.where((contact) => contact.name == widget.groupList[widget.index].name).toList();
    _contactsList = widget.contactsList;
    _groupContactsList = _contactsList.where((contact) => _groupContactsMapping.any((groupContacts) => contact.id == groupContacts.contactId)).toList();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupList[widget.index].name),
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
                      decoration: const InputDecoration(labelText: 'Group Name'),
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
                        child: const Text('Rename'),
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
                _apiClient.editGroup();
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
                        _apiClient.removeContactFromGroup();
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
        builder: (context) => AddContactsListScreen(contactsList: _contactsList, contactsToExclude: contactsInGroup),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      //##Tutaj wstawić logikę dodawania kontaktu do grupy w back-endzie
      _apiClient.addContactToGroup();
      setState(() {
        _groupContactsList.addAll(selectedContacts);
      });
    }
  }
}

class AddContactsListScreen extends StatefulWidget {
  final List<Contact> contactsList;
  final List<Contact> contactsToExclude;
  const AddContactsListScreen({super.key, required this.contactsList, required this.contactsToExclude});

  @override
  _AddContactsListScreenState createState() => _AddContactsListScreenState();
}

class _AddContactsListScreenState extends State<AddContactsListScreen> {
  List<Contact> _addableContactsList = [];
  List<Contact> _nonAddableContactsList = [];
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    initializeContacts();
  }

  Future<void> initializeContacts() async {
    _addableContactsList = widget.contactsList;
    _addableContactsList = _addableContactsList.where((contact) => contact.isRegistered).toList();
    _addableContactsList = _addableContactsList.where((newContact) => !widget.contactsToExclude.any((existingContact) => existingContact.id == newContact.id)).toList();

    _nonAddableContactsList = widget.contactsList;
    _nonAddableContactsList = _nonAddableContactsList.where((contact) => !contact.isRegistered).toList();
    setState(() {

    });
  }

  final List<Contact> _selectedContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildAddContactsGroup('People using MeetMeThere', _addableContactsList, true),
                _buildAddContactsGroup('Invite to MeetMeThere', _nonAddableContactsList, false),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedContacts);
              },
              child: const Text('Add Selected Contacts'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactsGroup(String title, List<Contact> contacts, bool addable) {
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
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: contacts.length,
          itemBuilder: (BuildContext context, int index) {
            Contact contact = contacts[index];
            bool isSelected = _selectedContacts.contains(contact);
            if (addable) {
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(contacts[index].name[0], style: TextStyle(color: Theme.of(context).colorScheme.primary))
                ),
                //leading: const Icon(Icons.account_box_outlined), //##docelowo powinna tutaj być jakaś ikonka usera
                title: Text(
                  contacts[index].name,
                  style: const TextStyle(fontSize: 12.0),
                ),
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
            }
            else {
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(contacts[index].name[0],
                        style: TextStyle(color: Theme.of(context).colorScheme.primary))
                ),
                //leading: const Icon(Icons.account_box_outlined), //##docelowo powinna tutaj być jakaś ikonka usera
                title: Text(
                  contacts[index].name,
                  style: const TextStyle(fontSize: 12.0),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!contacts[index].isRegistered)
                      IconButton(
                        icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'This action will create an invitation text message ready to be sent. Do you want to continue?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.grey)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Continue'),
                                    onPressed: () {
                                      //##Tutaj wstawić logikę wysyłania zaproszenia w back-endzie
                                      _apiClient.sendInvitation(
                                          'Hi! Check out MeetMeThere app where you can easily notify your friends where they can meet you. Here\'s the link: TUTAJ LINK',
                                          [contacts[index].phoneNumber]);
                                      setState(() {

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
              );
            }
          },
        ),
      ],
    );
  }
}

class AddGroupsListScreen extends StatefulWidget {
  final List<Group> groupsList;
  final List<Group> groupsToExclude;
  const AddGroupsListScreen({super.key, required this.groupsList, required this.groupsToExclude});

  @override
  _AddGroupsListScreenState createState() => _AddGroupsListScreenState();
}

class _AddGroupsListScreenState extends State<AddGroupsListScreen> {
  List<Group> _addableGroupsList = [];

  @override
  void initState() {
    super.initState();
    initializeGroups();
  }

  Future<void> initializeGroups() async {
    _addableGroupsList = widget.groupsList;
    _addableGroupsList = _addableGroupsList.where((newGroup) => !widget.groupsToExclude.any((existingGroup) => existingGroup.name == newGroup.name)).toList();
    setState(() {

    });
  }

  final List<Group> _selectedGroups = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _addableGroupsList.length,
              itemBuilder: (BuildContext context, int index) {
                Group group = _addableGroupsList[index];
                bool isSelected = _selectedGroups.contains(group);
                return ListTile(
                  title: Text(group.name),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGroups.remove(group);
                      } else {
                        _selectedGroups.add(group);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, _selectedGroups);
            },
            child: const Text('Add Selected Groups'),
          ),
        ],
      ),
    );
  }
}