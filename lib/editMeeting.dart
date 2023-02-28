import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';

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
  Duration _duration = Duration(hours: 2, minutes: 30); //#will be dynamic
  final Color color = Colors.orange.shade700;
  final DateTime _selectedDateTime = DateTime.now();

  String _formatDateTime(DateTime dateTime) {
    //return DateFormat.yMd(myLocale.languageCode).format(now) //Implement later
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  _EditMeetingState(this.place, this._meetingStarted, this._headerText);

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
                color: color,
              ),
            ),
          ),
          Text(_formatDateTime(_selectedDateTime).toString(),
              style: const TextStyle(
                  fontSize: 12
              )
          ),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
              ),
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
          SizedBox(
            width:160,
            child: Text('Is scheduled to last for:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
          //#Dopracować wygląd i działanie
          DurationPicker(),
          /*Text('${_duration.inHours.remainder(24).toString().padLeft(2, '0')}:${(_duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12
            )
          ),*/
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(color),
              ),
              onPressed: () => {

              },
              child: const Text('Change', style: TextStyle(fontSize: 10))
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
                color: color,
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
                    color: color,
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
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(color),
              ),
              onPressed: () => {

              },
              child: const Text('End meeting', style: TextStyle(fontSize: 10))
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
        title: Text(_headerText),
        backgroundColor: color,
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

//#Wydzielić do osobnej klasy
class DurationPicker extends StatefulWidget {
  @override
  _DurationPickerState createState() => _DurationPickerState();
}

//This duration picker isn't perfect, but for now it's ok. Change it later (especially to select from something other than clock)
class _DurationPickerState extends State<DurationPicker> {
  Duration _duration = Duration(hours: 2, minutes: 30);

  Future<void> _selectDuration(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _duration.inHours, minute: _duration.inMinutes % 60),
    );

    if (time != null) {
      setState(() {
        _duration = Duration(hours: time.hour, minutes: time.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDuration(context),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_duration.inHours.remainder(24).toString().padLeft(2, '0')}:${(_duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}