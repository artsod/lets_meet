import 'package:flutter/material.dart';
import '../widgets/duration_picker.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/attendees_list.dart';
import '../screens/contacts_screen.dart';
import '../model/contact.dart';
import '../model/group.dart';
import '../model/meeting.dart';
import '../model/place.dart';
import '../api/api_client.dart';

enum ActionOnButton {New,Update,Cancel,End,Join,Decline,None}

class MeetingScreen extends StatefulWidget {
  final NonCachableGooglePlace place;
  final List<Contact> contactsList;
  final Meeting? meeting;

  const MeetingScreen({
    super.key,
    required this.place,
    required this.contactsList,
    this.meeting
  });

  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {

  //All default values for New meeting status. If meeting is passed (meaning status is different than New) all values are set in initState.
  late CachableGooglePlace _place;
  late Status _status=Status.Scheduled;
  late String _ownerID;
  DateTime _startDateTime = DateTime.now();
  Duration _duration = const Duration(hours: 1);
  final List<Contact> _participantsContacts = [];
  final List<Group> _participantsGroups = [];
  bool _showStartNowSwitch = true;
  bool _startNow = false;
  bool _startDateTimeEnabled = true;
  bool _durationEnabled = true;
  bool _addParticipantsEnabled = true;
  bool _addCommentEnabled = true;
  bool _showSecondButton = false;
  List<Group> _groupsList = [];
  String _screenTitle = '';
  String _firstButtonText = '';
  String _dateTimeText = '';
  String _durationText = '';
  String _participantsText = '';
  String _secondButtonText = '';
  late FocusNode _textFieldFocusNode;
  late ActionOnButton _firstButtonAction;
  late ActionOnButton _secondButtonAction;


  @override
  void initState() {
    super.initState();
    setMeetingVariables();
    _textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void setMeetingVariables() {
    _place = CachableGooglePlace(
        googlePlaceID: widget.place.googlePlaceID,
        googlePlaceLatLng: widget.place.googlePlaceLatLng,
        ownName: widget.place.googleName,
        ownIconUrl: 'assets/defaultPlaceIcon.png'
    );
    if (widget.meeting == null) {
      _status = Status.New;
      _screenTitle = 'Let\'s meet here';
      _ownerID = '111'; //currentUserID; ##jak to zrobić? Na razie fake na potrzeby testów
      _firstButtonText ='Let\'s meet here later';
      _dateTimeText = 'When will you be here?';
      _durationText = 'How long do you plan to be here?';
      _participantsText = 'Who do you invite?';
      _firstButtonAction = ActionOnButton.New;
    } else {
      _status = widget.meeting!.status;
      _ownerID = widget.meeting!.owner.id;
      if (_ownerID == '111') { //##tu ma być currentUserID - jak to zrobić?
        switch (_status) {
          case Status.Scheduled:
            _screenTitle = 'This meeting is scheduled';
            _firstButtonText = 'Update meeting';
            _dateTimeText = 'Meeting is planned at:';
            _durationText = 'How long do you plan to be here?';
            _participantsText = 'Who do you invite?';
            _secondButtonText = 'Cancel meeting';
            _showSecondButton = true;
            _firstButtonAction = ActionOnButton.Update;
            _secondButtonAction = ActionOnButton.Cancel;
            break;
          case Status.Started:
            _screenTitle = 'This meeting is in progress';
            _firstButtonText = 'Update meeting';
            _dateTimeText = 'Meeting has started at:';
            _durationText = 'Meeting is planned for:';
            _participantsText = 'You invited:';
            _secondButtonText = 'End meeting';
            _showStartNowSwitch = false;
            _startDateTimeEnabled = false;
            _showSecondButton = true;
            _firstButtonAction = ActionOnButton.Update;
            _secondButtonAction = ActionOnButton.End;
            break;
          case Status.Finished:
            _screenTitle = 'This meeting has already finished';
            _firstButtonText = 'Do nothing :)';
            _dateTimeText = 'Meeting has started at:';
            _durationText = 'Meeting was planned for:';
            _participantsText = 'You invited:';
            _showStartNowSwitch = false;
            _startDateTimeEnabled = false;
            _durationEnabled = false;
            _addParticipantsEnabled = false;
            _addCommentEnabled = false;
            _firstButtonAction = ActionOnButton.None;
            break;
          default:
            _screenTitle = 'This meeting is in unknown state';
            _firstButtonText = 'Do nothing :)';
            _dateTimeText = 'Meeting is planned at:';
            _durationText = 'Meeting was planned for:';
            _participantsText = 'You invited:';
            _showStartNowSwitch = false;
            _startDateTimeEnabled = false;
            _durationEnabled = false;
            _addParticipantsEnabled = false;
            _addCommentEnabled = false;
            _firstButtonAction = ActionOnButton.None;
            break;
        }
      } else {
        _firstButtonText = 'Join meeting';
        _dateTimeText = 'Meeting is planned at:';
        _durationText = 'Meeting is planned for:';
        _participantsText = 'People and groups invited:';
        _secondButtonText = 'Decline meeting';
        _showStartNowSwitch = false;
        _startDateTimeEnabled = false;
        _durationEnabled = false;
        _addParticipantsEnabled = false;
        _addCommentEnabled = false;
        _showSecondButton = true;
        _firstButtonAction = ActionOnButton.Join;
        _secondButtonAction = ActionOnButton.Decline;
      }
    }
  }

  Future<void> initializeGroups() async {
    _groupsList = await ApiClient().getGroups();
  }

  void navigateToAddContacts() async {
    List<Contact>? selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactsListScreen(contactsList: widget.contactsList, contactsToExclude: _participantsContacts),
      ),
    );

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      //##Tutaj wstawić logikę dodawania ludzi do spotkania w back-endzie
      //##.addContactToMeeting();
      setState(() {
        _participantsContacts.addAll(selectedContacts);
      });
    }
  }

  void navigateToAddGroups() async {
    List<Group>? selectedGroups = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGroupsListScreen(groupsList: _groupsList, groupsToExclude: _participantsGroups),
      ),
    );

    if (selectedGroups != null && selectedGroups.isNotEmpty) {
      //##Tutaj wstawić logikę dodawania grup do spotkania w back-endzie
      //##.addGroupToMeeting();
      setState(() {
        _participantsGroups.addAll(selectedGroups);
      });
    }
  }

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
                  widget.place.googleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                widget.place.vicinity,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget startNowSwitchSection = Visibility(
      visible: _showStartNowSwitch,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Start meeting now?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
            ),
          ),
          Switch(
            value: _startNow,
            activeColor: Theme
                .of(context)
                .colorScheme
                .primary,
            onChanged: (bool value) {
              _textFieldFocusNode.unfocus();
              setState(() {
                _startNow = value;
                if (value == true) {
                  _firstButtonText = 'Let\'s meet here now';
                } else {
                  _firstButtonText = 'Let\'s meet here later';
                }
              });
            },
          ),
        ],
      ),
    );

    Widget dateTimeSection = Visibility(
      visible: !_startNow,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 170,
                child: Text(_dateTimeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              DateTimePicker(
                enabled: _startDateTimeEnabled,
                onChanged: (dateTime) {
                  setState(() {
                    _startDateTime = dateTime;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    Widget durationSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_durationText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        DurationPicker(
          initialDuration: _duration,
          enabled: _durationEnabled,
          onTap: (newDuration) {
            setState(() {
              _duration = newDuration;
            });
          },
        )
      ],
    );

    Widget contactsSection = Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_participantsText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Row(
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(2.0)),
                          minimumSize: MaterialStateProperty.all<Size>(const Size(70, 25)),
                          backgroundColor: _addParticipantsEnabled ? Theme.of(context).elevatedButtonTheme.style!.backgroundColor : MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: _addParticipantsEnabled ? () {_textFieldFocusNode.unfocus(); navigateToAddContacts();} : null,
                        child: const Text('Add people', style: TextStyle(fontSize: 10))
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(2.0)),
                          minimumSize: MaterialStateProperty.all<Size>(const Size(70, 25)),
                          backgroundColor: _addParticipantsEnabled ? Theme.of(context).elevatedButtonTheme.style!.backgroundColor : MaterialStateProperty.all<Color>(Colors.grey),
                        ),
                        onPressed: _addParticipantsEnabled ? () {_textFieldFocusNode.unfocus(); initializeGroups(); navigateToAddGroups();} : null,
                        child: const Text('Add groups', style: TextStyle(fontSize: 10))
                    ),
                  ]),
            ]
        ),
        if ((_participantsContacts.isEmpty && _participantsGroups.isEmpty))
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No one is invited',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        Row(
          children: [
            AttendeesList(attendeesList: _participantsContacts),
          ],
        ),
        Row(
          children: [
            AttendeesList(attendeesList: _participantsGroups),
          ],
        ),
      ],
    );

    Widget commentSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meeting comments: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 4),
        TextField(
          enabled: _addCommentEnabled,
          focusNode: _textFieldFocusNode,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(fontSize: 10),
          maxLines: 5,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8.0),
            border: const OutlineInputBorder(),
            fillColor: _addCommentEnabled ? Colors.white : Colors.grey.shade300,
            filled: true,
          ),
          onChanged: (value) {

          },
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
                onPressed: () {
                  switch (_firstButtonAction) {//##Tutaj wstawić odpowiednie akcje w back-endzie
                    case ActionOnButton.New:
                      break;
                    case ActionOnButton.Update:
                      break;
                    case ActionOnButton.Join:
                      break;
                    case ActionOnButton.None:
                      break;
                    default:
                      break;
                  }
                },
                child: Text(_firstButtonText, style: const TextStyle(fontSize: 10))
            ),
          ),
          const SizedBox(width: 10),
          Visibility(
            visible: _showSecondButton,
            child: Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    switch (_secondButtonAction) {//##Tutaj wstawić odpowiednie akcje w back-endzie
                      case ActionOnButton.Decline:
                        break;
                      case ActionOnButton.End:
                        break;
                      case ActionOnButton.Cancel:
                        break;
                      default:
                        break;
                    }
                  },
                  child: Text(_secondButtonText, style: const TextStyle(fontSize: 10))
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
            ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                onPressed: () {Navigator.pop(context);},
                child: const Text('Back', style: TextStyle(fontSize: 10))
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        _textFieldFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screenTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (widget.place.placePhotoReference.isNotEmpty)
                      Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photo_reference=${widget.place.placePhotoReference}&key=AIzaSyDWBhV1GqMnWxUjMDHiGHLNqvuthU8nUcE',
                        width:500,
                        height:240,
                        fit: BoxFit.cover,
                      )
                    else
                      Image.asset(
                        'assets/no_photo.jpg',//##zdjęcie z depositphotos bez licencji, zmienić później
                        width: 500,
                        height: 240,
                        fit:BoxFit.cover,
                      ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          titleSection,
                          _showStartNowSwitch ? startNowSwitchSection : const SizedBox(height: 10),
                          dateTimeSection,
                          durationSection,
                          contactsSection,
                          commentSection,
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
      ),
    );
  }
}
