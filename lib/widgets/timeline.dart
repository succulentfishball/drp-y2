import 'dart:typed_data';
import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/widgets/photo_modal.dart';
import 'package:drp/data_types/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool isLocalImage(String? path) {
  return path != null && (path.startsWith('/') || path.startsWith('file://'));
}

class TimelineNodeWidget extends StatefulWidget {
  final Post post;
  const TimelineNodeWidget({super.key, required this.post});

  @override
  TimelineNodeWidgetState createState() => TimelineNodeWidgetState();
}

class TimelineNodeWidgetState extends State<TimelineNodeWidget> with AutomaticKeepAliveClientMixin {
  final p1 = "authorDisplayName";
  final p2 = "creationTime";
  Future<Uint8List?>? imgData;
  Future<Map<String, dynamic>>? labelData;

  @override
  void initState() {
    String? firstImgID = widget.post.imageIDs![0];

    // Future data
    imgData = BackEndService.fetchImageFromCloudByID(firstImgID!);
    labelData = Future(() async {
      final authorDisplayName = await BackEndService.fetchNameFromUUID(widget.post.authorID!);
      final img = await BackEndService.fetchImageDataFromDB(widget.post.imageIDs![0]);
      final time = img!.creationTime;
      
      return Future.value({
        p1: authorDisplayName,
        p2: time
      });
    });

    super.initState();
  }

  Widget buildLabels(Post post) {
    // Create future function to communicate with backend
    return FutureBuilder<Map<String, dynamic>>(
      future: labelData,
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        String authorDisplayName = "";
        DateTime creationTime = DateTime.now();
        if (snapshot.connectionState == ConnectionState.waiting){
          authorDisplayName = 'loading...';
        } else {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            authorDisplayName = snapshot.data![p1];
            creationTime = snapshot.data![p2];
          } else {
            authorDisplayName = "No data :(";
            creationTime = DateTime.now();
          }
        }

        // Generate label widgets
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              authorDisplayName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            Text(
              "${DateFormat.yMMMMd().format(creationTime)} ${DateFormat('jm').format(creationTime)}",
              style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize, color: Theme.of(context).colorScheme.onPrimaryFixedVariant)
            ),
          ],
        );
      }
    );
  }

  Widget buildImage() {
    return FutureBuilder(
      future: imgData, 
      builder: (context, snapshot) {
        print("Future interaction building image in timeline.dart");
        if (snapshot.hasError) {
          return Text("Error encountered");
        } else if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.fitWidth,
          );
        } else {
          return Text("Loading image...");
        }
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    String? caption = widget.post.caption;

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
                      child: buildLabels(widget.post)
                    ),
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => PhotoModal(post: widget.post),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: buildImage()
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
                    if (caption != null && caption != '') (
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: 
                        Text(
                          caption,
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

  @override
  bool get wantKeepAlive => true;
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
  Widget? kids;

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
              post: widget.photos[index].post
            );
        },
      )
    );
  }
}
