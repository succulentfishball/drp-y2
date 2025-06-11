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

          // Scroll to the bottom after the data is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });

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

ScrollController scrollController = ScrollController();
void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

class TimelineWidgetState extends State<TimelineWidget> {
  String? _selectedTag;
  List<String> get _allTags =>                             
      widget.photos.map((n) => n.post.tag).where((t) => t != null).cast<String>().toSet().toList();
  List<String?> get _pagesTags => [null, ..._allTags]; // null represents 'All'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
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
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SizedBox(
            height: 38, // just enough to contain the pills
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: List.generate(_pagesTags.length, (i) {
                  final tag = _pagesTags[i];
                  final label = tag ?? 'All';
                  final isSelected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTag = tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFC1B39B) : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                            right: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
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
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/chatbackground/binder.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: ListView.separated(
                  reverse: true,
                  controller: scrollController,
                  itemCount: filteredPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, id) {
                    final idx = filteredPhotos.length - id - 1;
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
              // Button to scroll to the bottom
              Positioned(
                bottom: 8,
                left: 8,
                child: FloatingActionButton(
                  onPressed: () {
                    scrollToBottom();
                  },
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
