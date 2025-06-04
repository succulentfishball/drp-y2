import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isLocalImage(String path) {
  return path.startsWith('/') || path.startsWith('file://');
}

class PhotoWidget extends StatefulWidget {
  final String imageUrl;
  final String caption;
  final DateTime dateTime;
  final String user;

  const PhotoWidget({super.key, required this.imageUrl, required this.dateTime, required this.user, this.caption = ''});

  @override
  PhotoWidgetState createState() => PhotoWidgetState();
}

class PhotoWidgetState extends State<PhotoWidget> {
  @override
  Widget build(BuildContext context) {
    return 
    IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // timeline vertical line
                Expanded(
                  child: Container(
                    height: 10,
                    width: 6,
                    color: Theme.of(context).colorScheme.surfaceTint,
                  ),
                ),
                // profile picture
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage('https://picsum.photos/100'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // timeline vertical line
                Expanded(
                  child: Container(
                    width: 6,
                    color: Theme.of(context).colorScheme.surfaceTint,
                  ),
                ),
              ],
            ),
            // timeline horizontal line
            Column(
              children: [
                Spacer(),
                Container(
                  width: 64,
                  height: 4,
                  color: Theme.of(context).colorScheme.surfaceTint,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                Spacer(),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.user,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleLarge?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                          Text(
                            "${DateFormat.yMMMMd().format(widget.dateTime)} ${DateFormat('jm').format(widget.dateTime)}",
                            style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryFixedVariant)
                          ),
                        ],
                      )
                    ),
                    Center(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: (isLocalImage(widget.imageUrl)) ?
                                Image.file(File(widget.imageUrl)) :
                                Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.fitWidth,
                                ),
                            ),
                          ),
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
                                "0 Replies",
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
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
            ),
          ]
      ),
    );
  }
}

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({super.key, required this.photos, required this.photoKeys});
  final List<PhotoWidget> photos;
  final List<GlobalKey<PhotoWidgetState>> photoKeys;

  @override
  State<TimelineWidget> createState() => TimelineWidgetState();
}

class TimelineWidgetState extends State<TimelineWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Find the most top visible PhotoWidget
    double mostTop = double.infinity;
    PhotoWidget? mostTopPhoto;

    for (var photo in widget.photos) {
      final RenderObject? renderObject = (photo.key is GlobalKey && (photo.key as GlobalKey).currentContext != null)
          ? (photo.key as GlobalKey).currentContext!.findRenderObject()
          : null;
      if (renderObject is RenderBox) {
        final position = renderObject.localToGlobal(Offset.zero);
        if (position.dy < mostTop) {
          mostTop = position.dy;
          mostTopPhoto = photo;
        }
      }
    }

    if (mostTopPhoto != null) {
      // Do something with the most top visible PhotoWidget
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Most top PhotoWidget: ${mostTopPhoto.caption}')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        // controller: _scrollController,
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return PhotoWidget(
              key: widget.photoKeys[index],
              imageUrl: widget.photos[index].imageUrl,
              dateTime: widget.photos[index].dateTime,
              user: widget.photos[index].user,
              caption: widget.photos[index].caption,
            );
        },
      )
    );
  }
}