import 'package:flutter/material.dart';
import 'model/groups_list_model.dart';
import 'package:provider/provider.dart';

class GroupsList extends StatefulWidget {
    _GroupsListState createState() => _GroupsListState();
}
class _GroupsListState extends State<GroupsList> {

    final GroupsListModel model =  GroupsListModel();

    @override
    Widget build(BuildContext context) {
        return Consumer<GroupsListModel> (
            builder: (context, list, child) { 
                return ListView.builder(
                    itemCount: list.contactGroups.length,
                    itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(list.contactGroups[index].name)
                        );
                    },
                );
            } 
        );
    }
}
