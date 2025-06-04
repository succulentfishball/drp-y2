import 'package:flutter/material.dart';
import 'package:drp/utils.dart' as utils;

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
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://picsum.photos/100'),
      ),
      title: Text(widget.user),
      subtitle: Text(widget.caption),
      trailing: Text("${utils.date(widget.dateTime)}\n${utils.time(widget.dateTime)}"),
    );
  }
}
