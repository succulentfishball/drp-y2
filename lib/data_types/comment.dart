import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? authorID;
  DateTime? postTime;
  String? message;

  Comment({this.authorID, this.postTime, this.message});

  factory Comment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Comment(
      authorID: data?['authorID'],
      postTime: DateTime.fromMillisecondsSinceEpoch(data?['postTime']),
      message: data?['message']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (authorID != null) "authorID": authorID,
      if (postTime != null) "postTime": postTime!.millisecondsSinceEpoch,
      if (message != null) "message": message
    };
  }
}