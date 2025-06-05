import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

bool isLocalImage(String path) {
  return path.startsWith('/') || path.startsWith('file://');
}

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
      trailing: Text("${DateFormat.yMMMMd().format(widget.dateTime)}\n${DateFormat('jm').format(widget.dateTime)}"),
    );
  }
}

class PhotoModal extends StatefulWidget {
  const PhotoModal({super.key, required this.data, required this.caption, required this.dateTime, required this.user});
  final Uint8List data;
  final String caption;
  final DateTime dateTime;
  final String user;

  @override
  PhotoModalState createState() => PhotoModalState();
}

class PhotoModalState extends State<PhotoModal> {
  final TextEditingController _controller = TextEditingController();
  List<CommentWidget> comments = [];

  @override
  void initState() {
    super.initState();
    comments = [
      if (widget.caption.isNotEmpty)
        CommentWidget(caption: widget.caption, dateTime: widget.dateTime, user: widget.user),
      CommentWidget(caption: "where is this?", dateTime: DateTime.now(), user: "me"),
      CommentWidget(caption: "we went xxx today, it was qwertyuiopasdfghjklzxcvbnm", dateTime: DateTime.now(), user: "Dad"),
    ];
  }

  void _addComment() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        comments.add(CommentWidget(
          caption: value,
          dateTime: DateTime.now(),
          user: "me",
        ));
        _controller.clear(); // Clear the text field after submission
      });
    }
  }

  void _addReaction() {
    // todo
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(8),
      contentPadding: const EdgeInsets.all(8),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // image
            ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SizedBox(
                width: double.infinity,
                child: Image.memory(
                  widget.data,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            // scrollable comment section
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return comments[index];
                  },
                ),
              ),
            ),
            // add comment input
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: _addReaction,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(8),
                    ),
                    onSubmitted: (_) {
                      _addComment();
                    }
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ]
        ),
      ),
    );
  }
}