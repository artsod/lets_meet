import 'dart:convert';
import 'dart:io';
//import 'package:http/http.dart' as http;

class LetsMeetApiClient {
  final String baseUrl;

  LetsMeetApiClient({required this.baseUrl});

  Future<List<dynamic>> fetchGroups() async {
      try {
          final file = File('data.json');
          final contents = file.readAsStringSync();
          final jsonData = jsonDecode(contents);
          // Do something with the data
      } on FileSystemException catch (e) {
          throw e.message;
      }
      //actual api implemenation
      //final response = await http.get(Uri.parse('$baseUrl/groups'));

      //if (response.statusCode == 200) {

      //final jsonData = jsonDecode(response.body) as List<dynamic>;
      //return jsonData;
      //} else {
      //throw Exception('Failed to fetch groups');
      //}
  }


  Future<void> inviteUser(String groupId, String email) async {
    final response = await http.post(Uri.parse('$baseUrl/groups/$groupId/invite'),
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('Failed to invite user to group');
    }
  }
}

