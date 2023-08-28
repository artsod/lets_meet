import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../model/contact.dart';
import '../model/group.dart';

class ContactsManagement extends StatefulWidget {

  final Map<String,String> labels;

  const ContactsManagement({super.key, required this.labels});

  @override
  _ContactsManagementState createState() => _ContactsManagementState();
}

class _ContactsManagementState extends State<ContactsManagement> {
  bool _showContacts = true;
  List<Contact> _contactsList = [];
  final ApiClient _apiClient = ApiClient();
  List<Group> _groupsList = [];

  @override
  void initState() {
    super.initState();
    initializeContacts();
    initializeGroups();
  }

  Future<void> initializeContacts() async {
    //##dorobić kółeczko z czekaniem na wczytanie kontaktów
    _contactsList = await _apiClient.getContactsLocal();
    setState(() {

    });
  }

  Future<void> initializeGroups() async {
    _groupsList = await _apiClient.getGroups();
  }

  void renameGroup(List<Group> updatedList) {
    setState(() {
      _groupsList = updatedList;
    });
  }

  //main structure widget - Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labels['contactsGroups']!),
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
                    child: Text(
                      widget.labels['contacts']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                    child: Text(
                      widget.labels['groups']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                _buildContactGroup(widget.labels['peopleUsingApp']!, registeredContacts),
                _buildContactGroup(widget.labels['inviteToApp']!, unregisteredContacts),
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
                              title: Text(widget.labels['confirm']!),
                              content: Text(widget.labels['sendInvitationText']!),
                              actions: [
                                TextButton(
                                  child: Text(widget.labels['cancel']!,style: const TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(widget.labels['continue']!),
                                  onPressed: () {
                                    //##Tutaj wstawić logikę wysyłania zaproszenia w back-endzie
                                    _apiClient.sendInvitation(widget.labels['invitationText']!, [contacts[index].phoneNumber]);
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
                            title: Text(widget.labels['confirm']!),
                            content: Text(widget.labels['sureToRemoveContact']!),
                            actions: [
                              TextButton(
                                child: Text(widget.labels['cancel']!,
                                    style: const TextStyle(color: Colors.grey)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(widget.labels['remove']!, style: const TextStyle(color: Colors.red)),
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
                _buildGroupTypeList(widget.labels['myPrivateGroups']!, _groupsList.where((group) => group.type == 'MyPrivate').toList()),
                _buildGroupTypeList(widget.labels['myPublicGroups']!, _groupsList.where((group) => group.type == 'MyPublic').toList()),
                _buildGroupTypeList(widget.labels['otherPublicGroups']!, _groupsList.where((group) => group.type == 'OtherPublic').toList()),
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
                      String groupType = widget.labels['private']!;
                      Group newGroup;
                      return StatefulBuilder(
                          builder: (context, setState)
                          {
                            return AlertDialog(
                              title: Text(widget.labels['createGroup']!),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        groupName = value;
                                      });
                                    },
                                    decoration: InputDecoration(labelText: widget.labels['groupName']),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: widget.labels['private']!,
                                        groupValue: groupType,
                                        onChanged: (value) {
                                          setState(() {
                                            groupType = value!;
                                          });
                                        },
                                      ),
                                      Text(widget.labels['private']!),
                                      Radio<String>(
                                        value: widget.labels['public']!,
                                        groupValue: groupType,
                                        onChanged: (value) {
                                          setState(() {
                                            groupType = value!;
                                          });
                                        },
                                      ),
                                      Text(widget.labels['public']!),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text(widget.labels['cancel']!,
                                      style: const TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                ),
                                TextButton(
                                  child: Text(widget.labels['create']!),
                                  onPressed: () {
                                    if (groupName.isNotEmpty) {
                                      if (groupType == widget.labels['private']) {
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
                child: Text(widget.labels['createGroup']!)
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.labels['noGroups']!,
              style: const TextStyle(color: Colors.grey),
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
                              title: Text(widget.labels['confirm']!),
                              content: Text(widget.labels['sureToRemoveGroup']!),
                              actions: [
                                TextButton(
                                  child: Text(widget.labels['cancel']!,
                                      style: const TextStyle(color: Colors.grey)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(widget.labels['remove']!,
                                      style: const TextStyle(color: Colors.red)),
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
                      builder: (context) => GroupContactsScreen(groupList: _groupsList, renameGroup: renameGroup, index: index, contactsList: _contactsList, labels: widget.labels),
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

class GroupContactsScreen extends StatefulWidget {
  final List<Group> groupList;
  final Function(List<Group>) renameGroup;
  final int index;
  final List<Contact> contactsList;
  final Map<String,String> labels;

  const GroupContactsScreen({super.key, required this.groupList, required this.renameGroup, required this.index, required this.contactsList, required this.labels});

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

  void _navigateToAddContacts(List<Contact> contactsInGroup) async {
    List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactsListScreen(contactsList: _contactsList, contactsToExclude: contactsInGroup, labels: widget.labels),
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
                    title: Text(widget.labels['enterNewName']!),
                    content: TextField(
                      controller: TextEditingController(text: widget.groupList[widget.index].name),
                      decoration: InputDecoration(labelText: widget.labels['groupName']!),
                      onChanged: (value) {
                        userInput = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        child: Text(widget.labels['cancel']!,
                            style: const TextStyle(color: Colors.grey)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(widget.labels['rename']!),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    widget.labels['noContactsInGroup']!,
                    style: const TextStyle(color: Colors.grey),
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
            child: Text(widget.labels['addPeople']!),
          ),
        ],
      ),
    );
  }
}

class AddContactsListScreen extends StatefulWidget {
  final List<Contact> contactsList;
  final List<Contact> contactsToExclude;
  final Map<String,String> labels;

  const AddContactsListScreen({super.key, required this.contactsList, required this.contactsToExclude, required this.labels});

  @override
  _AddContactsListScreenState createState() => _AddContactsListScreenState();
}

class _AddContactsListScreenState extends State<AddContactsListScreen> {
  List<Contact> _addableContactsList = [];
  List<Contact> _nonAddableContactsList = [];
  final ApiClient _apiClient = ApiClient();
  final List<Contact> _selectedContacts = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labels['contactsList']!),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildAddContactsGroup(widget.labels['peopleUsingApp']!, _addableContactsList, true),
                _buildAddContactsGroup(widget.labels['inviteToApp']!, _nonAddableContactsList, false),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedContacts);
              },
              child: Text(widget.labels['addSelectedContacts']!),
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
                                title: Text(widget.labels['confirm']!),
                                content: Text(widget.labels['sendInvitationText']!),
                                actions: [
                                  TextButton(
                                    child: Text(widget.labels['cancel']!,
                                        style: const TextStyle(color: Colors.grey)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(widget.labels['continue']!),
                                    onPressed: () {
                                      //##Tutaj wstawić logikę wysyłania zaproszenia w back-endzie
                                      _apiClient.sendInvitation(widget.labels['invitationText']!, [contacts[index].phoneNumber]);
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
  final Map<String,String> labels;

  const AddGroupsListScreen({super.key, required this.groupsList, required this.groupsToExclude, required this.labels});

  @override
  _AddGroupsListScreenState createState() => _AddGroupsListScreenState();
}

class _AddGroupsListScreenState extends State<AddGroupsListScreen> {
  List<Group> _addableGroupsList = [];
  final List<Group> _selectedGroups = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labels['groupsList']!),
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
            child: Text(widget.labels['addSelectedGroups']!),
          ),
        ],
      ),
    );
  }
}