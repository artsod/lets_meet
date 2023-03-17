import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';


class OrganizeMeeting extends StatefulWidget {
  final PlaceDetails place;

  OrganizeMeeting(this.place);

  @override
  _OrganizeMeetingState createState() => _OrganizeMeetingState(place);
}

class _OrganizeMeetingState extends State<OrganizeMeeting> {

  final PlaceDetails place;
  final Color color = Colors.orange.shade700;
  late String _startMeetingText = 'Let\'s meet here now';
  bool startNow=true;
  DateTime _selectedDateTime = DateTime.now();
  Duration _duration = const Duration();

  _OrganizeMeetingState(this.place);

  Future<void> selectDuration(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _duration.inHours, minute: _duration.inMinutes % 60),
    );

    setState(() {
      if (time != null) {
        _duration = Duration(hours: time.hour, minutes: time.minute);
      } else {
        _duration = const Duration(hours:0, minutes: 0);
      }
    });
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
          Container(
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
        GestureDetector(
          onTap: () {
            setState(() {
              selectDuration(context);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_duration.inHours.remainder(24).toString().padLeft(2, '0')}:${(_duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );

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
          Row(
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(color),
                  ),
                  onPressed: () => {

                  },
                  child: Text('Select people', style: TextStyle(fontSize: 10))
              ),
              Text('People you have selected'),
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
          Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photo_reference=${place.photos.first.photoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
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
                durationSection,
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

class DateTimePicker extends StatefulWidget {
  final Function(DateTime) onChanged;

  const DateTimePicker({Key? key, required this.onChanged}) : super(key: key);

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _dateTime;
  final Color _color=Colors.orange.shade700;
  //Locale myLocale = Localizations.localeOf(this.context); //Implement later

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showDateTimePicker,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 12),
            Text(_formatDateTime(_dateTime)),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _color, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _color, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
        //Find a way to merge those two builders to format time picker
        /*builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: _color, // <-- SEE HERE
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: _color, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },*/
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        }
      );
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _dateTime = dateTime;
        });
        widget.onChanged(dateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    //return DateFormat.yMd(myLocale.languageCode).format(now) //Implement later
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}