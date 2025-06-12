import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:flutter/material.dart';
import 'package:drp/widgets/photo_modal.dart';
import 'package:drp/widgets/comment_modal.dart';
import 'package:drp/widgets/edit_post_modal.dart';

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

Map<String, (String, Color)> postTags = {
  "Reminds me of home": ("assets/photoframes/homeFrame.jpg", Colors.orangeAccent.shade100),
  "Trying to Chef!": ("assets/photoframes/foodFrame.jpg", Colors.orange),
  "Guess what?": ("assets/photoframes/guessWhatFrame.jpg", Colors.lightBlue),
  "What changed at home": ("assets/photoframes/whatsChangedFrame.jpg", Colors.blueAccent.shade100),
  "Guess the price!": ("assets/photoframes/guessPriceFrame.jpg", Colors.green),
  "This made me think of you...": ("assets/photoframes/thinkOfYouFrame.jpg", Colors.yellow.shade100),
  "Postcards from home": ("assets/photoframes/postcardFrame.jpg", Colors.deepPurple.shade200),
  "Save for when we meet": ("assets/photoframes/saveFrame.jpg", Colors.red.shade400),
  "Pets from home": ("assets/photoframes/petFrame.jpg", Colors.redAccent.shade100),
};

class PostWidgetState extends State<PostWidget> {
  DecorationImage? _getFrameDecoration() {
    final tagData = postTags[widget.tag];
    if (tagData != null) {
      final (path, color) = tagData;
      return DecorationImage(
        image: AssetImage(path),
        fit: BoxFit.fill,
      );
    }
    return null;
  }

  Widget _getTagPill() {
    final tagColor = postTags[widget.tag]?.$2 ?? Colors.white.withOpacity(0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.tag,
        style: TextStyle(
          letterSpacing: -1,
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCustomFrame = postTags.keys.contains(widget.tag);
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: GestureDetector(
          onLongPress: () {
            // buttons to show edit tag, edit caption, delete post
            showDialog(
              context: context,
              builder: (context) {
                return EditPostModal(post: widget.post!);
              }
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  image: _getFrameDecoration(),
                  color: hasCustomFrame ? null : Colors.grey.shade100,
                  border: hasCustomFrame ? Border.all(color: Colors.black, width: 2) : Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      spreadRadius: 4,
                      blurRadius: 3,
                      offset: Offset(3, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // details for user and time at the top
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Author pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.authorDisplayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Spacer(),
                        // Tag pill
                        if (widget.tag.isNotEmpty)
                          _getTagPill(),
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
                            // date time watermark
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Text(
                                widget.creationDisplayTime,
                                style: TextStyle(
                                  letterSpacing: -0.5,
                                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                                  fontFamily: 'monospace',
                                  color: Colors.amber,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 4.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // comment bubble with click detector
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.post != null) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        BackEndService.incrementPostsOpened();
                                        return CommentModal(post: widget.post!);
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(180),
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
                                          return Row(
                                            children: [
                                              Text("$x",
                                                style: TextStyle(
                                                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.comment,
                                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                size: 20,
                                              ),
                                            ]
                                          );
                                        }
                                      },
                                    ) 
                                  ) : Row(
                                    children: [
                                      Text("0"),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.comment,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        size: 16,
                                      ),
                                    ]
                                  ),
                                )
                              ),
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
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                child: Image.asset(
                          'assets/icons/push-pin.png',
                          width: 48,
                          height: 48,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
