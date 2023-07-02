import 'place.dart';
import 'contact.dart';
import 'group.dart';

enum Status {New,Scheduled,Started,Finished}

class Meeting {
  CachableGooglePlace place;
  Status status; //can be 'New','Scheduled','Started','Finished'
  Contact owner;
  DateTime startDateTime;
  Duration duration;
  List<Contact> participantsContacts;
  List<Group> participantsGroups;
  String comment;

  Meeting({
    required this.place,
    required this.status,
    required this.owner,
    required this.startDateTime,
    required this.duration,
    this.participantsContacts = const [],
    this.participantsGroups = const [],
    this.comment = ''
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      place: json['place'] as CachableGooglePlace,
      status: json['status'] as Status,
      owner: json['owner'] as Contact,
      startDateTime: json['startDateTime'] as DateTime,
      duration: json['duration'] as Duration,
      participantsContacts: json['participantsContacts'] as List<Contact>,
      participantsGroups: json['participantsGroups'] as List<Group>,
      comment: json['comment'] as String,
    );
  }
}