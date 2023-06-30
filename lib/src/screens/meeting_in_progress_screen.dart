import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class MeetingInProgress extends StatefulWidget {
  final PlaceDetails place;

  const MeetingInProgress(this.place);

  @override
  _MeetingInProgressState createState() => _MeetingInProgressState(place);
}

class _MeetingInProgressState extends State<MeetingInProgress> {

  PlaceDetails place;
  final DateTime _selectedDateTime = DateTime.now();

  _MeetingInProgressState(this.place);

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

    Widget timeSection = Column(
      children: [
        Row(
            children: const [
              Text('Your meeting is scheduled until:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ]
        ),
        Text(_selectedDateTime.toString()
        ),
      ],
    );

    Widget contactsSection = Column(
      children: [
        Row(
            children: const [
              Text('People that wanted to meet with you here',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
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
              onPressed: () {Navigator.pop(context);},
              child: const Text('Cancel', style: TextStyle(fontSize: 10))
          ),
        ),
        const SizedBox(width: 20),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('You\'re currently in the meeting'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&maxheight=240&photo_reference=${place.photos.first.photoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
            width:600,
            height:240,
                fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                titleSection,
                timeSection,
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