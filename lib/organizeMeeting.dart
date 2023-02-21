import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class OrganizeMeeting extends StatefulWidget {
  final PlaceDetails place;

  OrganizeMeeting(this.place);

  @override
  _OrganizeMeetingState createState() => _OrganizeMeetingState(place);
}

class _OrganizeMeetingState extends State<OrganizeMeeting> {

  final PlaceDetails place;
  final Color color = Colors.orange.shade700;
  late String _startMeetingText = 'Start meeting now';
  bool startNow=true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  _OrganizeMeetingState(this.place);

  @override
  Widget build(BuildContext context) {

    Widget titleSection = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*2*/
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
          'Start meeting now?',
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
                _startMeetingText='Start meeting now';
              } else {
                _startMeetingText='Start meeting later';
              }
            });
          },
        ),
      ],
    );

    Widget timeSection = Visibility(
      visible: !startNow,
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(color),
                ),
                onPressed: () => _selectDate(context),
                child: Text('Select date', style: TextStyle(fontSize: 10)),
              ),
              Text('Selected date: ${_selectedDate.toString()}'),
            ]
          ),
          Row(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(color),
                ),
                onPressed: () => _selectTime(context),
                child: Text('Select time', style: TextStyle(fontSize: 10)),
              ),
              Text('Selected time: ${_selectedTime.toString()}'),
            ]
          ),
        ],
      ),
    );

    Widget buttonSection = Row(
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
              child: Text(_startMeetingText, style: TextStyle(fontSize: 10))
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child:
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
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Let\'s meet here'),
        backgroundColor: color,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&maxheight=240&photo_reference=${place.photos.first.photoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
            //'images/lake.jpg',
            width:600,
            height:240,
                fit: BoxFit.cover,
          ),
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                titleSection,
                switchSection,
                timeSection,
                buttonSection,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: color, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: color, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: color, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: color, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}