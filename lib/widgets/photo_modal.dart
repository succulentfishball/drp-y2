import 'package:drp/backend_services/backend_service.dart';
import 'package:drp/data_types/my_post.dart';
import 'package:flutter/material.dart';

class PhotoModal extends StatefulWidget {
  const PhotoModal({super.key, required this.post});
  final MyPost post;

  @override
  PhotoModalState createState() => PhotoModalState();
}

class PhotoModalState extends State<PhotoModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(8),
      contentPadding: const EdgeInsets.all(8),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: FutureBuilder(
            future: BackEndService.fetchImageFromCloudByID(widget.post.imageIDs![0]), 
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Loading image...");
              } else {
                return Image.memory(snapshot.data!, fit: BoxFit.fitWidth);
              }
            }
          ),
        ),
      ),
    );
  }
}
