import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import '../widgets/duration_picker.dart';

class EditMeeting extends StatefulWidget {
  final PlaceDetails place;
  final bool meetingStarted;
  final String headerText;

  const EditMeeting(this.place,this.meetingStarted, this.headerText);

  @override
  _EditMeetingState createState() => _EditMeetingState(place, meetingStarted, headerText);
}

class _EditMeetingState extends State<EditMeeting> {

  PlaceDetails place;
  final bool _meetingStarted;
  final String _headerText;
  Duration _duration = const Duration();
  final DateTime _selectedDateTime = DateTime.now();

  _EditMeetingState(this.place, this._meetingStarted, this._headerText);

  String _formatDateTime(DateTime dateTime) {
    //return DateFormat.yMd(myLocale.languageCode).format(now) //Implement later
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

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

    Widget startTimeSection = Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 160,
            child: Text('Your meeting has started on:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Text(_formatDateTime(_selectedDateTime).toString(),
              style: const TextStyle(
                  fontSize: 12
              )
          ),
          ElevatedButton(
              onPressed: !_meetingStarted ? () => {} : null,
              child: const Text('Change', style: TextStyle(fontSize: 10))
          ),
        ],
      ),
    );

    Widget durationSection = Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Is scheduled to last for: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          DurationPicker(
            initialDuration: _duration,
            onTap: (newDuration) {
              setState(() {
                _duration = newDuration;
              });
            },
          ),
        ],
      ),
    );

    Widget endTimeSection = Container(
      padding: EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width:160,
            child: Text('So it will end on:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Text(_formatDateTime(_selectedDateTime.add(_duration)).toString(),
              style: const TextStyle(
                  fontSize: 12
              )
          ),
        ],
      ),
    );

    Widget contactsSection = Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child:Column(
        children: [
          Row(
              children: [
                Text('People that wanted to meet with you here',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]
          ),
          Row(
            children: const [
              Text('People with you'),
            ],
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
              onPressed: () => {

              },
              child: const Text('End meeting', style: TextStyle(fontSize: 10))
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child:
          ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
              onPressed: () {Navigator.pop(context);},
              child: const Text('Cancel', style: TextStyle(fontSize: 10))
          ),
        ),
        const SizedBox(width: 20),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_headerText),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photo_reference=${place.photos.first.photoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
            width:600,
            height:240,
                fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                titleSection,
                startTimeSection,
                durationSection,
                endTimeSection,
                contactsSection,
                buttonSection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}