import 'package:flutter/material.dart';
import '../model/contact.dart';
import '../model/group.dart';


class AttendeesList extends StatefulWidget {
  final List<dynamic> attendeesList;

  const AttendeesList({super.key, required this.attendeesList});

  @override
  _AttendeesListState createState() => _AttendeesListState();
}

class _AttendeesListState extends State<AttendeesList> {
  late List<dynamic> attendeesList = widget.attendeesList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
        Wrap(
          spacing: 2.0,
          runSpacing: -14.0,
          children: List.generate(
            attendeesList.length,
                (index) => _buildAttendeeChip(attendeesList[index]),
          ),
        ),

    );
  }

  Widget _buildAttendeeChip(Object attendee) {
    return Chip(
      label: Text(
        () {
          if (attendee is Contact) {
            return attendee.name;
          } else if (attendee is Group) {
            return attendee.name;
          } else {
            return '';
          }
        }(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      padding: const EdgeInsets.all(0.0),
      labelPadding: const EdgeInsets.only(top: -4.0, bottom: -4.0, left: 6.0),
      onDeleted: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          attendeesList.remove(attendee);
        });
      },
    );
  }
}
