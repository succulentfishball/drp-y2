import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:drp/photo_modal.dart';
import 'package:drp/utils.dart' as utils;

class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.data, required this.caption, required this.dateTime, required this.user});
  final Uint8List data;
  final String caption;
  final DateTime dateTime;
  final String user;

  @override
  PostWidgetState createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // details for user and time at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  Text(
                    "${utils.date(widget.dateTime)} ${utils.time(widget.dateTime)}",
                    style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryFixedVariant)
                  ),
                ],
              )
            ),
            // image with click detector
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        //   const PhotoModal({super.key, required this.data, required this.caption, required this.dateTime, required this.user});
                        builder: (context) => PhotoModal(data: widget.data, caption: widget.caption, dateTime: widget.dateTime, user: widget.user),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: utils.getImageFromBytes(widget.data),
                      ),
                    ),
                  ),
                  // reply count
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(200),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        // todo replies
                        "2 Replies",
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
            // caption at the bottom
            if (widget.caption.isNotEmpty && widget.caption != '') (
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: 
                Text(
                  widget.caption,
                  style: TextStyle(fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer)
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}