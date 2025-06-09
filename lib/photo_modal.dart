
import 'package:drp/backend_service.dart';
import 'package:drp/main.dart';
import 'package:drp/post.dart';
import 'package:flutter/material.dart';
import 'package:drp/comment_widget.dart';

class PhotoModal extends StatefulWidget {
  const PhotoModal({super.key, required this.post});
  final Post post;

  @override
  PhotoModalState createState() => PhotoModalState();
}

class PhotoModalState extends State<PhotoModal> {
  final TextEditingController _controller = TextEditingController();
  List<CommentWidget> comments = [];

  @override
  void initState() {
    super.initState();
  }

  Future<CommentWidget> _buildPostComment() async {
    final String? username = await BackEndService.fetchNameFromUUID(widget.post.authorID!);
    return CommentWidget(caption: widget.post.caption!, dateTime: widget.post.postTime!, user: username!);
  }

  List<CommentWidget> _dummyComments() {
    return [
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
                child: FutureBuilder(
                  future: BackEndService.fetchImageFromCloudByID(widget.post.imageIDs![0]), 
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading image...");
                    } else {
                      return Image.memory(snapshot.data!, fit: BoxFit.fitWidth);
                    }
                  }
                )
              ),
            ),
            // scrollable comment section
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                // This will require stream builder
                child: FutureBuilder(
                  future: _buildPostComment(), 
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) { return Text("Loading comments..."); }

                    comments.add(snapshot.data!);
                    
                    // Dummy comments
                    if (testMode) { 
                      comments.addAll(_dummyComments()); 
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return comments[index];
                      },
                    );
                  }
                )
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
