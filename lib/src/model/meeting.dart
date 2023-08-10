import 'place.dart';
import 'contact.dart';
import 'group.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

enum Status {New,Scheduled,Started,Finished}

class Meeting {
  CachableGooglePlace place;
  Status status;
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
    final googlePlaceID = json['place']['googlePlaceID'] as String;
    final latitude = json['place']['googlePlaceLatLng']['latitude'] as double;
    final longitude = json['place']['googlePlaceLatLng']['longitude'] as double;
    final googlePlaceLatLng = LatLng(latitude, longitude);
    final ownName = json['place']['ownName'] as String;
    final ownIconUrl = json['place']['ownIconUrl'] as String;
    final place = CachableGooglePlace(googlePlaceID: googlePlaceID, googlePlaceLatLng: googlePlaceLatLng, ownName: ownName, ownIconUrl: ownIconUrl);
    final status = Status.values.byName(json['status']);
    final id = json['owner']['id'] as String;
    final name = json['owner']['name'] as String;
    final email = json['owner']['email'] as String;
    final phoneNumber = json['owner']['phoneNumber'] as String;
    final isRegistered = json['owner']['isRegistered'] as bool;
    final owner = Contact(id: id, name: name, email: email, phoneNumber: phoneNumber, isRegistered: isRegistered);
    final startDateTime = DateTime.parse(json['startDateTime']);
    List<String> timeParts = json['duration'].split(':');
    final duration = Duration(hours: int.parse(timeParts[0]), minutes: int.parse(timeParts[1]), seconds: int.parse(timeParts[2]));
    //##uzupełnić o czytanie uczestników
    //final participantsContacts = json['participantsContacts'] as List<Contact>;
    //final participantsGroups = json['participantsGroups'] as List<Group>;
    final comment = json['comment'] as String;

    return Meeting(
        place: place,
        status: status,
        owner: owner,
        startDateTime: startDateTime,
        duration: duration,
        participantsContacts: [],
        participantsGroups: [],
        comment: comment
    );
  }
}