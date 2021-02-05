import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerUser {
  String name, gameId, message, uid, twitter, imagePath;
  int like;
  Timestamp createAt;
  CustomerUser(
      {this.createAt,
      this.gameId,
      this.like,
      this.message,
      this.twitter,
      this.uid,
      this.name,
      this.imagePath});
}
