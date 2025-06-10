import 'package:flutter/material.dart';
import 'package:drp/widgets/photo_modal.dart';
import 'package:drp/data_types/my_post.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.image, required this.authorDisplayName, required this.creationDisplayTime, required this.caption, required this.tag, required this.replyCount, this.post});
  final Widget image;
  final String authorDisplayName;
  final String creationDisplayTime;
  final String caption;
  final String tag;
  final int replyCount;
  // post will only exist if it is part of the timeline
  final Post? post;

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
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCustomFrame = widget.tag == "Trying to Chef!" || widget.tag == "Pets from home";
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            image: _getFrameDecoration(),
            color: hasCustomFrame ? null : Colors.white,
            border: hasCustomFrame ? null : Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // details for user and time at the top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.authorDisplayName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                      Text(
                        widget.creationDisplayTime,
                        style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryFixedVariant)
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // image with click detector if not posting
                  GestureDetector(
                    onTap: () {
                      if (widget.post != null) {
                        showDialog(
                          context: context,
                          builder: (context) => PhotoModal(post: widget.post!),
                        );
                      }
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8 * 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: widget.image,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // caption at the bottom
                  if (widget.caption != '') (
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: 
                      Text(
                        widget.caption,
                        style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer, backgroundColor: Colors.white)
                      ),
                    )
                  ),
                ]
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(200),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    // todo replies
                    "${widget.replyCount} Replies",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
