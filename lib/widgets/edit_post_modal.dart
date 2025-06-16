import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:flutter/material.dart';

class EditPostModal extends StatefulWidget {
  const EditPostModal({super.key, required this.post});
  final MyPost post;

  @override
  EditPostModalState createState() => EditPostModalState();
}

class EditPostModalState extends State<EditPostModal> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Post Options", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // edit caption
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Edit Caption"),
                        content: TextField(
                          controller: TextEditingController(text: widget.post.caption),
                          onSubmitted: (newCaption) {
                            // BackEndService.updatePostCaption(widget.post!, newCaption);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  );
                },
                child: Text("Edit Caption"),
              ),
              ElevatedButton(
                onPressed: () {
                  // edit tag
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Edit Tag"),
                        content: TextField(
                          controller: TextEditingController(text: widget.post.tag),
                          onSubmitted: (newTag) {
                            // BackEndService.updatePostTag(widget.post!, newTag);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  );
                },
                child: Text("Edit Tag"),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer),
                ),
                onPressed: () {
                  // delete post
                  // BackEndService.deletePost(widget.post!);
                  Navigator.pop(context);
                },
                child: Text("Delete Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
