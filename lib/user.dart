import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  String? groupID;
  String? name;

  MyUser({this.groupID, this.name});

  factory MyUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyUser(
      name: data?['name'],
      groupID: data?['groupID']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (groupID != null) "groupID": groupID
    };
  }
}