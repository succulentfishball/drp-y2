
import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/comment.dart';
import 'package:drp/main.dart';
import 'package:drp/data_types/post.dart';
import 'package:flutter/material.dart';
import 'package:drp/widgets/comment_widget.dart';

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
    comments.add(
      CommentWidget(
        comment: Comment(
          message: widget.post.caption!, 
          postTime: widget.post.postTime!, 
          authorID: widget.post.authorID!
        )
      )
    );
    
    super.initState();
  }

  void _addComment() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        comments.add(CommentWidget(comment: Comment(
          message: value,
          postTime: DateTime.now(),
          authorID: BackEndService.userID,
        )));
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return comments[index];
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
