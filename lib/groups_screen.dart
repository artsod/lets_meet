import 'package:flutter/material.dart';
import 'groups_list.dart';
class GroupsScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Your Social Groups'),
            ),
            body: GroupsList(),
        );
    }

