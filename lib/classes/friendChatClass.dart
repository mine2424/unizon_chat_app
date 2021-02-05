import 'package:cloud_firestore/cloud_firestore.dart';

class FriendChats {
  String userId, context, name, imagePath;
  int like;
  Timestamp createAt;

  FriendChats({this.name, this.context, this.createAt, this.like, this.userId});
}
