import 'dart:typed_data';
import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:drp/widgets/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:drp/utilities/utils.dart' as utils;
import 'dart:math';

class TimelineNodeWidget extends StatefulWidget {
  final MyPost post;
  const TimelineNodeWidget({super.key, required this.post});

  @override
  TimelineNodeWidgetState createState() => TimelineNodeWidgetState();
}

class TimelineNodeWidgetState extends State<TimelineNodeWidget> with AutomaticKeepAliveClientMixin {
  Widget buildPostWidget(MyPost post) {
    final Future<String?> authorDisplayNameFuture = BackEndService.fetchNameFromUUID(post.authorID!);
    final Future<Uint8List?> imgDataFuture = BackEndService.fetchImageFromCloudByID(post.imageIDs![0]);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        authorDisplayNameFuture,
        imgDataFuture,
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting && !snapshot.hasError && snapshot.hasData) {
          String authorDisplayName = snapshot.data![0] ?? '';
          DateTime creationTime = post.timeFirstImageTaken!;

          return PostWidget(
              image: Image.memory(
                snapshot.data![1],
                fit: BoxFit.fitWidth,
              ),
              authorDisplayName: authorDisplayName,
              creationDisplayTime: utils.dateAndTime(creationTime),
              caption: widget.post.caption ?? '',
              tag: widget.post.tag ?? '',
              replyCount: 0,
              post: widget.post,
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text("Loading post... (${snapshot.error})"));
          } else {
            return Center(child: Text("Loading post... (no data)"));
          }
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var isMyPost = BackEndService.userID == widget.post.authorID;

    const maxRot = 6;
    const maxShift = 24;

    final random = Random();
    double rotationAngle = (random.nextDouble() * 2 * maxRot - maxRot) * (pi / 180);
    // shift towards center only
    double shiftX = (isMyPost ? -1 : 1) * random.nextDouble() * maxShift;

    return Row(
      mainAxisAlignment: isMyPost ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Transform.translate(
            offset: Offset(shiftX, 0),
            child: Transform.rotate(
              angle: rotationAngle,
              child: buildPostWidget(widget.post),
            ),
          ),
        ),
      ]
    );

    // IntrinsicHeight(
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: [
    //         Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             // timeline vertical line
    //             Expanded(
    //               child: Container(
    //                 height: 10,
    //                 width: 6,
    //                 color: Theme.of(context).colorScheme.surfaceTint,
    //               ),
    //             ),
    //             // profile picture
    //             Container(
    //               width: 64,
    //               height: 64,
    //               decoration: BoxDecoration(
    //                 shape: BoxShape.circle,
    //                 color: Theme.of(context).colorScheme.surfaceContainer
    //               ),
    //               child: Icon(
    //                 Icons.person,
    //                 size: 32,
    //                 color: Theme.of(context).colorScheme.onSurfaceVariant
    //               ),
    //             ),
    //             // timeline vertical line
    //             Expanded(
    //               child: Container(
    //                 width: 6,
    //                 color: Theme.of(context).colorScheme.surfaceTint,
    //               ),
    //             ),
    //           ],
    //         ),
    //         // timeline horizontal line
    //         Column(
    //           children: [
    //             Spacer(),
    //             Container(
    //               width: 32,
    //               height: 4,
    //               color: Theme.of(context).colorScheme.surfaceTint,
    //               margin: EdgeInsets.symmetric(horizontal: 8),
    //             ),
    //             Spacer(),
    //           ],
    //         ),
    //         // actual post container
    //         Expanded(
    //           child: buildPostWidget(widget.post),
    //         ),
    //       ]
    //   ),
    // );
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
