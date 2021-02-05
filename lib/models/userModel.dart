import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unizon_chat_app/classes/users.dart';
import 'package:unizon_chat_app/common/constant/auth.dart';

class UserModel extends ChangeNotifier {
  CustomerUser customerInfo;
  List<CustomerUser> customerUserList;
  bool isLoading = false;

  Future<void> fetchCustomerInfo() async {
    this.isLoading = true;
    var customerInfo;

    customerInfo = await FirebaseFirestore.instance
        .collection('customerInfo')
        .doc(authUserId)
        .get()
        .then((value) => CustomerUser(
            uid: value.data()['uid'],
            name: value.data()['insta'],
            gameId: value.data()['gameId'],
            twitter: value.data()['twitter'],
            like: value.data()['like'],
            message: value.data()['message'],
            createAt: value.data()['createAt'],
            imagePath: value.data()['imagePath']));

    this.isLoading = false;
    this.customerInfo = customerInfo;
    notifyListeners();
  }

  Future<void> fetchSelectedCustomerInfo(String userUid) async {
    this.isLoading = true;
    var customerInfo;
    //customerInfoからuser画像を取得
    final customerUserInfo = await FirebaseFirestore.instance
        .collection('customerInfo')
        .doc(userUid)
        .get()
        .then((value) => value.data()['imagePath']);
    //仮にキーが存在していなかったらからで取得
    if (customerUserInfo == '' || customerUserInfo == null) {
      customerInfo = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(userUid)
          .get()
          .then((value) => CustomerUser(
              uid: value.data()['uid'],
              name: value.data()['insta'],
              gameId: value.data()['gameId'],
              twitter: value.data()['twitter'],
              like: value.data()['like'],
              message: value.data()['message'],
              createAt: value.data()['createAt'],
              imagePath: ''));
    } else {
      customerInfo = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(userUid)
          .get()
          .then((value) => CustomerUser(
              uid: value.data()['uid'],
              name: value.data()['insta'],
              gameId: value.data()['gameId'],
              twitter: value.data()['twitter'],
              like: value.data()['like'],
              message: value.data()['message'],
              createAt: value.data()['createAt'],
              imagePath: value.data()['imagePath']));
    }

    this.isLoading = false;
    this.customerInfo = customerInfo;
    notifyListeners();
  }
}
