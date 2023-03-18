import 'package:flutter/material.dart';
import 'model/group.dart'
import 'package:provider/provider.dart';

class GroupsList extends StatefulWidget {
    _GroupsListState createState() => _GroupsListState();
}
Class _GroupsListState {
    List<
  @override
  Widget build(BuildContext context) {
      return Consumer<ContactGroupModel> (builder: (context, group, child) => 
          const Scaffold(
              body: Center(
                  child: Text('Tutaj będzie zarządzenie kontaktami'),
              ),
          );
    }
}
