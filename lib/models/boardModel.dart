import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unizon_chat_app/classes/friendChatClass.dart';

class BoardModel extends ChangeNotifier {
  bool isLoading = true;
  List chatsList;
  Future<void> fetchFriendComments() async {
    this.isLoading = true;
    //snapshotsで取得
    final allFriendChats = await FirebaseFirestore.instance
        .collection('friendChats')
        .orderBy('createAt', descending: true)
        .get();
    for (var i = 0; i < allFriendChats.docs.length; i++) {
      chatsList.add(FriendChats(
        name: allFriendChats.docs[i].data()['name'],
        context: allFriendChats.docs[i].data()['context'],
        createAt: allFriendChats.docs[i].data()['createAt'],
        like: allFriendChats.docs[i].data()['like'],
        userId: allFriendChats.docs[i].data()['uid'],
      ));
    }
    this.isLoading = false;
    notifyListeners();
  }
}
