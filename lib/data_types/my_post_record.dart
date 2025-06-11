import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp/data_types/enums.dart';

class MyPostRecord {
  String? authorID;
  Method? method;
  DateTime? uploadTime;
  Duration? postWritingDuration;
  String? tag;

  MyPostRecord({this.authorID, this.method, this.uploadTime, this.postWritingDuration, this.tag});

  factory MyPostRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyPostRecord(
      authorID: data?['authorID'],
      method: data?['method'] == "camera" ? Method.camera : Method.gallery,
      uploadTime: DateTime.fromMillisecondsSinceEpoch(data?['uploadTime']),
      postWritingDuration: Duration(milliseconds: data?['postWritingTime']),
      tag: data?['tag'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (authorID != null) "authorID": authorID,
      if (method != null) "method": method.toString(),
      if (uploadTime != null) "uploadTime": uploadTime!.millisecondsSinceEpoch,
      if (postWritingDuration != null) "postWritingTime": postWritingDuration!.inMilliseconds,
      if (tag != null) "tag": tag
    };
  }
}