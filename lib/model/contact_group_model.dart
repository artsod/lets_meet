import 'package:flutter/widgets.dart';
import 'contact_group.dart';
import '../api/lets_meet_api_client.dart';

class ContactGroupModel extends ChangeNotifier {
    final LetsMeetApiClient _apiClient = LetsMeetApiClient();
    List<ContactGroup> _contactGroups = [];
    bool _isLoading = false;
    String _errorMessage = '';

    List<ContactGroup> get contactGroups => _contactGroups;
    bool get isLoading => _isLoading;
    bool get hasError => _errorMessage.isNotEmpty;
    String get errorMessage => _errorMessage;

    ContactGroupModel (BuildContext context);

    Future<void> fetchContacts() async {
        Map<String, dynamic> jsonObject = await _apiClient.fetchGroups();
        try {
            //Clear out any existing data. 
            _contactGroups.clear();
            final List<ContactGroup> groups = [];

            for (final groupJson in jsonObject.values) {
                ContactGroup newGroup = ContactGroup.fromJson(groupJson);
                groups.add(newGroup);
            }

            // Update the contact groups and loading state
            _contactGroups = groups;
            _isLoading = false;
            notifyListeners();

        } catch (error) {
            // Handle the error
            _isLoading = false;
            _errorMessage = error.toString();
        }
    }
}

