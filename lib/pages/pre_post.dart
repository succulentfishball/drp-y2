import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:drp/widgets/post_widget.dart';
import 'package:drp/utilities/utils.dart' as utils;
import 'package:drp/backend_services/backend_service.dart';


class PrePostPage extends StatefulWidget {
  final XFile imageFile;
  final void Function({required String caption, String? tag, required XFile image}) onPost;

  const PrePostPage({super.key, required this.imageFile, required this.onPost});

  @override
  State<PrePostPage> createState() => _PrePostPageState();
}

class _PrePostPageState extends State<PrePostPage> with SingleTickerProviderStateMixin {
  final TextEditingController _captionController = TextEditingController();
  bool _showTags = false;
  String? _selectedTag;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleTagDropdown() {
    setState(() => _showTags = !_showTags);
    _showTags ? _animationController.forward() : _animationController.reverse();
  }

  void clearTag() {
    setState(() => _selectedTag = null);
  }

  Color getTagColor(String tag) {
    return postTags[tag]!.$2;
  }

  @override
  // Careful about using null checker on widget.post
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Transform.scale(
            scale: 1 / 0.6,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: PostWidget(
                  image: Image.file(
                    File(widget.imageFile.path),
                    fit: BoxFit.cover,
                  ),
                  authorDisplayName: 'me',
                  creationDisplayTime: utils.dateAndTime(DateTime.now()),
                  caption: _captionController.text,
                  tag: _selectedTag ?? '',
                  replyCount: 0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showTags)
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        height: 300,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: postTags.keys.map((tag) => RadioListTile<String>(
                            title: Text(tag),
                            value: tag,
                            groupValue: _selectedTag,
                            onChanged: (value) => setState(() {
                              _selectedTag = value;
                              _showTags = false;
                              _animationController.reverse();
                            }),
                          )).toList(),
                        ),
                      ),
                    ),
                  // Tags side scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: 
                      Row(
                        children: [
                          GestureDetector(
                            onTap: toggleTagDropdown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.label_outline, size: 20),
                                  const SizedBox(width: 6),
                                  const Text("Tag", style: TextStyle(fontSize: 16)),
                                  if (_selectedTag != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        _selectedTag!,
                                        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedTag != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: clearTag,
                            ),
                          const SizedBox(width: 12),
                          
                          if (_selectedTag == null) 
                            FutureBuilder<List<String>>(
                              future: BackEndService.getRecentTags(),
                              builder: (context, snap) {
                                if (!snap.hasData || snap.data!.isEmpty)
                                  return const SizedBox();
                                final recent = snap.data!;
                                // map each of the 2 tags to a pill
                                return Row(
                                  children: recent.map((tag) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedTag = tag;
                                            _showTags = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: getTagColor(tag),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                        ],
                      ),
                  ),

                  const SizedBox(height: 8),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _captionController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: "Add a caption...",
                              border: InputBorder.none,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (_captionController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a caption.")),
                            );
                            return;
                          }
                          widget.onPost(
                            caption: _captionController.text,
                            tag: _selectedTag,
                            image: widget.imageFile,
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
