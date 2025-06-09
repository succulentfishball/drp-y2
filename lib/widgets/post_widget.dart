import 'dart:typed_data';

import 'package:drp/backend_service.dart';
import 'package:drp/post.dart';
import 'package:flutter/material.dart';
import 'package:drp/utils.dart' as utils;

class PostWidget extends StatefulWidget {
  const PostWidget({super.key, required this.post});
  final Post post;

  @override
  PostWidgetState createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  Future<Uint8List?>? imgData;

  @override
  void initState() {
    super.initState();
    if (widget.post.imageIDs != null && widget.post.imageIDs!.isNotEmpty) {
      imgData = BackEndService.fetchImageFromCloudByID(widget.post.imageIDs![0]);
    }
  }

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
                    BackEndService.userID!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  Text(
                    "${utils.date(widget.post.postTime!)} ${utils.time(widget.post.postTime!)}",
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
                    // onTap: () {
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) => PhotoModal(imageUrl: widget.imageUrl, caption: widget.caption, dateTime: widget.dateTime, user: widget.user),
                    //   );
                    // },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FutureBuilder<Uint8List?>(
                          future: imgData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                              return const Center(child: Icon(Icons.broken_image));
                            } else {
                              return Image.memory(snapshot.data!);
                            }
                          },
                        ),
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
            if (widget.post.caption!.isNotEmpty && widget.post.caption! != '') (
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: 
                Text(
                  widget.post.caption!,
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