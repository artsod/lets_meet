import 'dart:convert';
import 'dart:io';
//import 'package:http/http.dart' as http;

class LetsMeetApiClient {
  //final String baseUrl;

  LetsMeetApiClient();

  Future<Map<String, dynamic>> fetchGroups() async {
      try {
          final file = File('data.json');
          final response = file.readAsStringSync();
          final  jsonObject= json.decode(response); 
          return jsonObject;
      } on FileSystemException catch (e) {
          throw e.message;
      }
      //actual api implemenation
      //final response = await http.get(Uri.parse('$baseUrl/groups'));

      //if (response.statusCode == 200) {

      //final jsonObject = jsonDecode(response.body) as List<dynamic>;
      //return jsonObject;
      //} else {
      //throw Exception('Failed to fetch groups');
      //}
  }


  //Future<void> inviteUser(String groupId, String email) async {
  //  final response = await http.post(Uri.parse('$baseUrl/groups/$groupId/invite'),
  //      body: jsonEncode({'email': email}),
  //      headers: {'Content-Type': 'application/json'});

  //  if (response.statusCode != 200) {
  //    throw Exception('Failed to invite user to group');
  //  }
  //}
}

