import 'package:flutter/material.dart';
import 'package:drp/utilities/utils.dart' as utils;

class CommentWidget extends StatefulWidget  {
  const CommentWidget({super.key, required this.caption, required this.dateTime, required this.user});
  final String caption;
  final DateTime dateTime;
  final String user;

  @override
  State<CommentWidget> createState() => CommentWidgetState();
}

class CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainer
        ),
        child: Icon(
          Icons.person,
          size: 32,
          color: Theme.of(context).colorScheme.onSurfaceVariant
        ),
      ),
      title: Text(widget.user),
      subtitle: Text(widget.caption),
      trailing: Text("${utils.date(widget.dateTime)}\n${utils.time(widget.dateTime)}"),
    );
  }
}
