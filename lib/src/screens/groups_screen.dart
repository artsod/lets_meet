import 'package:flutter/material.dart';
import 'src/model/groups_list_model.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget {
    const GroupsScreen({super.key});

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: Text('Your Social Groups'),
            ),
            body: _GroupsList(),
        );

    }
}

class _GroupsList extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        var list = context.watch<GroupsListModel>();

        return Column(
                children: [
                        Text('Count of items: ' + list.contactGroups.length.toString()),
                        ListView.builder(
                            itemCount: list.contactGroups.length,
                            itemBuilder: (context, index) {
                                var list = context.read<GroupsListModel>();
                                return ListTile(
                                    title: Text(list.contactGroups[index].name)
                                );
                            }
                        ),
                ],
               
            );
    }
}
