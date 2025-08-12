import 'package:flutter/material.dart';

class TaskDemo extends StatefulWidget {
  const TaskDemo({super.key});

  @override
  State<TaskDemo> createState() => _TaskDemoState();
}

class _TaskDemoState extends State<TaskDemo> {
  var myTiles = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReorderableListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            key: Key("$index"),
            title: Text(myTiles[index].toString()),
            tileColor: Colors.red,
          );
        },
        itemCount: myTiles.length,
        onReorder: (oldIndex, newIndex) {},
      ),
    );
  }
}
