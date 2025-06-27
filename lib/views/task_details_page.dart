import 'package:flutter/material.dart';
import 'package:unstack/theme/app_theme.dart';

class TaskDetailsPage extends StatefulWidget {
  final String heroTag;
  const TaskDetailsPage({required this.heroTag, super.key});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag,
      child: Scaffold(
        backgroundColor: AppColors.accentBlue,
        appBar: AppBar(),
      ),
    );
  }
}
