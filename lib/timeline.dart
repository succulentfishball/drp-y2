import 'package:flutter/material.dart';
import 'package:drp/post_widget.dart';

class TimelineNodeWidget extends StatefulWidget {
  final String imageUrl;
  final String caption;
  final DateTime dateTime;
  final String user;

  const TimelineNodeWidget({super.key, required this.imageUrl, required this.dateTime, required this.user, this.caption = ''});

  @override
  TimelineNodeWidgetState createState() => TimelineNodeWidgetState();
}

class TimelineNodeWidgetState extends State<TimelineNodeWidget> {
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
                    color: Theme.of(context).colorScheme.surfaceContainer
                  ),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant
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
            // actual timeline post
            PostWidget(imageUrl: widget.imageUrl, caption: widget.caption, dateTime: widget.dateTime, user: widget.user),
          ]
      ),
    );
  }
}

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({super.key, required this.photos, required this.photoKeys});
  final List<TimelineNodeWidget> photos;
  final List<GlobalKey<TimelineNodeWidgetState>> photoKeys;

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
    // Find the most top visible TimelineWidget
    double mostTop = double.infinity;
    TimelineNodeWidget? mostTopPhoto;

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
      // Do something with the most top visible TimelineWidget
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Most top TimelineWidget: ${mostTopPhoto.caption}')),
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
          return TimelineNodeWidget(
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
