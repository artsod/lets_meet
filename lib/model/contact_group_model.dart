import 'dart:convert';
import 'package:http/http.dart' as http;
import 'contact_group.dart';

class ContactGroupModel {
  List<ContactGroup> _contactGroups = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ContactGroup> get contactGroups => _contactGroups;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage.isNotEmpty;
  String get errorMessage => _errorMessage;

  Future<void> fetchContacts() async {
    _isLoading = true;
    _errorMessage = '';

    try {
      // Fetch data from API
      final response = await http.get(Uri.parse('https://your-api-url.com/contact-groups'));

      // Decode the response body
      final data = jsonDecode(response.body);

      // Clear the existing contact groups
      _contactGroups.clear();

      // Create a new list of contact groups from the response data
      final List<ContactGroup> groups = [];

      for (final groupData in data) {
        final group = ContactGroup.fromJson(groupData);
        groups.add(group);
      }

      // Update the contact groups and loading state
      _contactGroups = groups;
      _isLoading = false;
    } catch (error) {
      // Handle the error
      _isLoading = false;
      _errorMessage = error.toString();
    }
  }
}

