import 'package:cloud_firestore/cloud_firestore.dart';

class MyImage {
  String? ownerID;
  DateTime? creationTime;

  MyImage({this.ownerID, this.creationTime});

  factory MyImage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyImage(
      ownerID: data?['ownerID'],
      creationTime: DateTime.fromMillisecondsSinceEpoch(data?['creationTime'])
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (ownerID != null) "ownerID": ownerID,
      if (creationTime != null) "creationTime": creationTime!.millisecondsSinceEpoch
    };
  }
}