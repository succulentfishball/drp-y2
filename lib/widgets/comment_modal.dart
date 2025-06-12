import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/comment.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:flutter/material.dart';
import 'package:drp/widgets/comment_widget.dart';

class CommentModal extends StatefulWidget {
  const CommentModal({super.key, required this.post});
  final MyPost post;

  @override
  CommentModalState createState() => CommentModalState();
}

class CommentModalState extends State<CommentModal> {
  final TextEditingController _controller = TextEditingController();
  List<CommentWidget> comments = [];

  void _addComment() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        BackEndService.addCommentToChatID(
          Comment(
            authorID: BackEndService.userID!,
            postTime: DateTime.now(),
            message: value
          ), 
          widget.post.chatID!
        );
        BackEndService.incrementTotalComments();
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
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // scrollable comment section
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: StreamBuilder(
                  stream: BackEndService.getAllCommentSnapshotsFromChat(widget.post.chatID!), 
                  builder: (context, snapshot) {
                    print("in builder");
                    if (snapshot.hasData) {
                      print("snapshot has data");
                      comments.clear();
                      for (final doc in snapshot.data!.docs) {
                        print("doc $doc");
                        comments.add(CommentWidget(comment: Comment.fromFirestore(doc, null)));
                        print("comments length = ${comments.length}");
                      }

                      comments.sort((a, b) => (a.comment.postTime!.compareTo(b.comment.postTime!)));

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return comments[index];
                        }
                      );

                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (_, _) {
                          return Text("Loading comments...");
                        }
                      );
                    }
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
