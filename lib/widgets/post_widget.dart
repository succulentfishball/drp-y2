import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:flutter/material.dart';
import 'package:drp/widgets/photo_modal.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.image, required this.authorDisplayName, required this.creationDisplayTime, required this.caption, required this.tag, required this.replyCount, this.post});
  final Widget image;
  final String authorDisplayName;
  final String creationDisplayTime;
  final String caption;
  final String tag;
  final int replyCount;
  // post will only exist if it is part of the timeline
  final MyPost? post;

  @override
  PostWidgetState createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  DecorationImage? _getFrameDecoration() {
    if (widget.tag == "Trying to Chef!") {
      return const DecorationImage(
        image: AssetImage("assets/photoframes/foodframe.png"),
        fit: BoxFit.fill,
      );
    } else if (widget.tag == "Pets from home") {
      return const DecorationImage(
        image: AssetImage("assets/photoframes/petframe.png"),
        fit: BoxFit.fill,
      );
    }
    else if (widget.tag == "Postcards from home") {
      return const DecorationImage(
        image: AssetImage("assets/photoframes/postcardframe.png"),
        fit: BoxFit.fill,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCustomFrame = widget.tag == "Trying to Chef!" || widget.tag == "Pets from home" || widget.tag == "Postcards from home";
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: BoxDecoration(
            image: _getFrameDecoration(),
            color: hasCustomFrame ? null : Colors.white,
            border: hasCustomFrame ? Border.all(color: Colors.black, width: 2) : Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // details for user and time at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Author pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),  // 85% opaque white
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.authorDisplayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                        color: Colors.black87,             // ensure legibility
                      ),
                    ),
                  ),
                ],
              ),
              // image with click detector if not posting
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (widget.post != null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                BackEndService.incrementPostsOpened();
                                return PhotoModal(post: widget.post!);
                              },
                            );
                          }
                        },
                        child: widget.image
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Text(
                          widget.creationDisplayTime,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                            fontFamily: 'monospace',
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(200),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: widget.post != null ? StreamBuilder(
                            stream: BackEndService.getAllCommentSnapshotsFromChat(widget.post!.chatID), 
                            builder: (_, _) => FutureBuilder(
                              future: BackEndService.getNumberOfRepliesToPost(widget.post),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text("... replies");
                                } else {
                                  final x = snapshot.data!;
                                  return Text(
                                    "$x ${x != 1 ? "replies" : "reply"}",
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  );
                                }
                              },
                            ) 
                          ) : Text("0 replies")
                        )
                      ),
                    ]
                  ),
                ),
              ),
              // caption at the bottom
              if (widget.caption != '') (
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.caption,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                        color: Colors.black87,
                      ),
                    ),
                  ), 
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}
