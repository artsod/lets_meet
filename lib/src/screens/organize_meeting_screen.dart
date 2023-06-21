import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import '../widgets/duration_picker.dart';
import '../widgets/date_time_picker.dart';
import '../screens/contacts_screen.dart';
import '../model/contact.dart';
import '../api/api_groups.dart';


class OrganizeMeeting extends StatefulWidget {
  final PlaceDetails place;
  final List<Contact> contactsList;

  const OrganizeMeeting({super.key, required this.place, required this.contactsList});

  @override
  _OrganizeMeetingState createState() => _OrganizeMeetingState();
}

class _OrganizeMeetingState extends State<OrganizeMeeting> {

  late PlaceDetails place = widget.place;
  final Color color = Colors.orange.shade700;
  late String _startMeetingText = 'Let\'s meet here now';
  bool startNow=true;
  DateTime _selectedDateTime = DateTime.now();
  Duration _duration = const Duration();
  List<Contact> _contactsList = [];
  List<Contact> _contactsInMeeting = [];
  List<Group> _groupsInMeeting = [];

  @override
  Widget build(BuildContext context) {

    Widget titleSection = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  place.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                place.vicinity ?? '',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget switchSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Are you here now?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
        Switch(
          value: startNow,
          activeColor: Colors.orange.shade700,
          onChanged: (bool value) {
            setState(() {
              startNow = value;
              if (value == true) {
                _startMeetingText='Let\'s meet here now';
              } else {
                _startMeetingText='Let\'s meet here later';
              }
            });
          },
        ),
      ],
    );

    Widget timeSection = Visibility(
      visible: !startNow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 170,
            child: Text('Select when will you be here',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
          DateTimePicker(
            onChanged: (dateTime) {
              setState(() {
                _selectedDateTime = dateTime;
              });
            },
          ),
        ],
      ),
    );

    Widget durationSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('How long do you plan to be here?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
        DurationPicker(
          initialDuration: _duration,
          onTap: (newDuration) {
            setState(() {
              _duration = newDuration;
            });
          },
        )
      ],
    );

    void navigateToAddContacts(List<Contact> contactsInMeeting) async {
      _contactsList = widget.contactsList;
      List<Contact>? selectedContacts = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddContactsListScreen(contactsList: _contactsList, contactsToExclue: contactsInMeeting),
        ),
      );
/*
      if (selectedContacts != null && selectedContacts.isNotEmpty) {
        //##Tutaj wstawić logikę dodawania ludzi do spotkania w back-endzie
        //##.addContactToMeeting();
        setState(() {
          _groupContactsList.addAll(selectedContacts);
        });
      }*/
    }

    Widget contactsSection = Column(
        children: [
          Row(
              children: [
                Text('With whom would you like to meet?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: color,
                  ),
                ),
              ]
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(color),
                  ),
                  onPressed: () {
                    navigateToAddContacts([]);
                  },
                  child: const Text('Select people', style: TextStyle(fontSize: 10))
              ),
              const Text('People you have selected'),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(color),
                  ),
                  onPressed: () {
                    //navigateToAddGroups([]);
                  },
                  child: const Text('Select groups', style: TextStyle(fontSize: 10))
              ),
              const Text('Groups you have selected'),
            ],
          ),
        ],
    );

    Widget buttonSection = Align(
      alignment: Alignment.bottomCenter,
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(color),
                ),
                onPressed: () => {

                },
                child: Text(_startMeetingText, style: const TextStyle(fontSize: 10))
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child:
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
                onPressed: () {Navigator.pop(context);},
                child: const Text('Cancel', style: TextStyle(fontSize: 10))
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Let\'s meet here'),
        backgroundColor: color,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photo_reference=${place.photos.first.photoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
                    width:500,
                    height:240,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        titleSection,
                        switchSection,
                        timeSection,
                        durationSection,
                        const SizedBox(height: 10),
                        contactsSection,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          buttonSection,
        ],
      ),
    );
  }
}
