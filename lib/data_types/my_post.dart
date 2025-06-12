import 'package:cloud_firestore/cloud_firestore.dart';

class MyPost {
  String? authorID;
  List? imageIDs;
  String? chatID;
  DateTime? postTime;
  DateTime? timeFirstImageTaken;
  String? caption;
  String? tag;

  MyPost({this.authorID, this.imageIDs, this.chatID, this.postTime, this.timeFirstImageTaken, this.caption, this.tag});

  factory MyPost.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyPost(
      authorID: data?['authorID'],
      imageIDs: data?['imageIDs'],
      chatID: data?['chatID'],
      postTime: DateTime.fromMillisecondsSinceEpoch(data?['postTime']),
      timeFirstImageTaken: DateTime.fromMillisecondsSinceEpoch(data?['timeFirstImageTaken'] ?? data?['postTime']),
      caption: data?['caption'],
      tag: data?['tag'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (authorID != null) "authorID": authorID,
      if (imageIDs != null) "imageIDs": imageIDs,
      if (chatID != null) "chatID": chatID,
      if (postTime != null) "postTime": postTime!.millisecondsSinceEpoch,
      if (timeFirstImageTaken != null) "timeFirstImageTaken": timeFirstImageTaken!.millisecondsSinceEpoch,
      if (caption != null) "caption": caption,
      if (tag != null) "tag": tag
    };
  }
}