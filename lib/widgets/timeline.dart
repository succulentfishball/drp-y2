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

    const maxRot = 4;
    const maxShift = 30;

    final random = Random();
    double rotationAngle = (random.nextDouble() * 2 * maxRot - maxRot) * (pi / 180);
    // shift towards center only
    double shiftX = (isMyPost ? -0.5 : 1) * random.nextDouble() * maxShift;

    return Padding(
      padding: EdgeInsetsGeometry.all(4),
      child: Row(
        // mainAxisAlignment: isMyPost ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisAlignment: (isMyPost ? MainAxisAlignment.end : MainAxisAlignment.start),
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
      ),
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
  String? _selectedTag;
  List<String> get _allTags =>                             
      widget.photos.map((n) => n.post.tag).where((t) => t != null).cast<String>().toSet().toList();
  List<String?> get _pagesTags => [null, ..._allTags]; // null represents 'All'

  
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

    final filteredPhotos = <TimelineNodeWidget>[];
    final filteredKeys = <GlobalKey<TimelineNodeWidgetState>>[];
    for (var i = 0; i < widget.photos.length; i++) {
      final node = widget.photos[i];
      if (_selectedTag == null || node.post.tag == _selectedTag) {
        filteredPhotos.add(node);
        filteredKeys.add(widget.photoKeys[i]);
      }
    }

return Column(
        children: [
        // Filter tabs molded into page (Chrome-style)
        // Tabs sit directly on the page background
          Container(
            color: Colors.white,
            child: SizedBox(
              height: 38, // just enough to contain the pills
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  children: List.generate(_pagesTags.length, (i) {
                    final tag = _pagesTags[i];
                    final label = tag == null ? 'All' : tag;
                    final isSelected = _selectedTag == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTag = tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFFC1B39B) : Colors.grey.shade200,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: isSelected ? Colors.brown.shade700 : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              left: BorderSide(
                                color: isSelected ? Colors.brown.shade700 : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              right: BorderSide(
                                color: isSelected ? Colors.brown.shade700 : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.brown.shade900 : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          // Timeline posts list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/chatbackground/binder.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: ListView.separated(

              controller: _scrollController,
              itemCount: filteredPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final post = filteredPhotos[idx].post;
                final isMyPost = BackEndService.userID == post.authorID;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMyPost) const SizedBox(width: 40), // extra offset from left
                    // Book spine on posts
                    Container(
                      width: 8,
                      color: Colors.brown.shade700,
                    ),
                    const SizedBox(width: 8),
                    // Post content
                    Expanded(
                      child: TimelineNodeWidget(
                        key: filteredKeys[idx],
                        post: filteredPhotos[idx].post,
                      ),
                    ),
                    // if (isMyPost) const SizedBox(width: 40), // extra offset from right
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
