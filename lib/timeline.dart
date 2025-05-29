import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
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
            child: SizedBox(
              // 80% of screen width
              // width: MediaQuery.of(context).size.width * 0.8,
              // full width
              width: double.infinity,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.fitWidth,
              ),
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
    );
  }
}

class TimelineWidget extends StatefulWidget {
  const TimelineWidget({super.key, required this.photos});
  final List<PhotoWidget> photos;

  @override
  State<TimelineWidget> createState() => TimelineWidgetState();
}

class TimelineWidgetState extends State<TimelineWidget> {
  late ScrollController _scrollController;
  List<GlobalKey<PhotoWidgetState>> _photoKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _photoKeys = List.generate(widget.photos.length, (_) => GlobalKey());
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Most top PhotoWidget: ${mostTopPhoto.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 50.0),
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: PhotoWidget(
              key: _photoKeys[index],
              imageUrl: widget.photos[index].imageUrl,
              dateTime: widget.photos[index].dateTime,
              user: widget.photos[index].user,
              caption: widget.photos[index].caption,
            ),
          );
        },
      )
    );
  }
}