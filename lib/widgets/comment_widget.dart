import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/comment.dart';
import 'package:flutter/material.dart';
import 'package:drp/utilities/utils.dart' as utils;

class CommentWidget extends StatefulWidget  {
  const CommentWidget({super.key, required this.comment});
  final Comment comment;

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
      title: FutureBuilder(
        future: BackEndService.fetchNameFromUUID(widget.comment.authorID!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("Loading username of author...");
          } else {
            return Text(snapshot.data!);
          }
        },
      ),
      subtitle: Text(widget.comment.message!),
      trailing: Text("${utils.date(widget.comment.postTime!)}\n${utils.time(widget.comment.postTime!)}"),
    ); 
  }
}
