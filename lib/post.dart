import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? authorID;
  List? imageIDs;
  DateTime? postTime;
  String? caption;

  Post({this.authorID, this.imageIDs, this.postTime, this.caption});

  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Post(
      authorID: data?['authorID'],
      imageIDs: data?['imageIDs'],
      postTime: DateTime.fromMillisecondsSinceEpoch(data?['postTime']),
      caption: data?['caption'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (authorID != null) "authorID": authorID,
      if (imageIDs != null) "imageIDs": imageIDs,
      if (postTime != null) "postTime": postTime!.millisecondsSinceEpoch,
      if (caption != null) "caption": caption
    };
  }
}