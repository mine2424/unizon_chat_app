import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unizon_chat_app/common/color/color.dart';
import 'package:unizon_chat_app/common/constant/auth.dart';
import 'package:unizon_chat_app/homeSection.dart';
import 'package:unizon_chat_app/models/userModel.dart';
import 'package:unizon_chat_app/prohibitionMatter/prohibitionWord.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class BottomAddCommentButton extends StatefulWidget {
  var chatLength;
  String collection;
  String sendUser;
  String messageUid;
  BottomAddCommentButton(
      {Key key,
      @required this.collection,
      this.chatLength,
      this.sendUser,
      this.messageUid})
      : super(key: key);
  @override
  _BottomAddCommentButtonState createState() => _BottomAddCommentButtonState();
}

class _BottomAddCommentButtonState extends State<BottomAddCommentButton> {
  var customerModel;
  final picker = ImagePicker();
  final approbation = 'https://hinatapicks.web.app/';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()..fetchCustomerInfo(),
      child: Consumer<UserModel>(
        builder: (context, model, child) {
          customerModel = model.customerInfo;
          return (model.isLoading)
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.only(bottom: 55),
                  child: FloatingActionButton(
                    heroTag: 'button1',
                    onPressed: () async {
                      return await showDialog(
                          context: context,
                          builder: (_) => AlertDialogSection(
                              customerModel: customerModel,
                              collection: widget.collection,
                              messageUid: widget.messageUid));
                    },
                    child: Icon(Icons.add),
                    backgroundColor: mainPurple,
                  ),
                );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class AlertDialogSection extends StatefulWidget {
  var customerModel, collection;
  String messageUid;

  AlertDialogSection(
      {Key key, this.customerModel, this.collection, this.messageUid})
      : super(key: key);
  @override
  _AlertDialogSectionState createState() => _AlertDialogSectionState();
}

class _AlertDialogSectionState extends State<AlertDialogSection> {
  String name, content, postImage;
  int like;
  Timestamp createAt;
  File _image;
  final picker = ImagePicker();
  final approbation = 'https://hinatapicks.web.app/';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //外部URLへページ遷移(webviewではない)
  static _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(
        link,
        universalLinksOnly: true,
        forceSafariVC: true,
        forceWebView: false,
      );
    } else {
      throw 'サイトを開くことが出来ません。。。 $link';
    }
  }

  TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () {
      _launchURL('https://hinatapicks.web.app/');
    };

  Future<void> getImageFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 60);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future<void> retrieveLostData() async {
    LostData response = await picker.getLostData();

    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file.toString());
      });
    } else {
      var _retrieveDataError = response.exception.code;
      print('RETRIEVE ERROR: ' + _retrieveDataError);
    }
  }

  Future<void> addComment(
      collection, customerModel, bool isPersonalRoom) async {
    if (_formKey.currentState.validate()) {
      print('start func');
      String userName, userImage = '';
      _formKey.currentState.save();
      // 各boardのcollectionを取得
      CollectionReference sendRoomComment, sendComment;
      if (isPersonalRoom) {
        sendRoomComment = FirebaseFirestore.instance
            .collection('friendChats')
            .doc(widget.messageUid)
            .collection('roomChats');
        print(sendRoomComment.toString());
      } else {
        sendComment = FirebaseFirestore.instance.collection(collection);
      }

      // print(sendComment.id);
      // 各Userのdocを取得
      final sendUserInfoDoc = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(authUserId)
          .get();
      //投稿するユーザーの画像の判別
      // print(sendUserInfoDoc.data()['imagePath']);
      if (sendUserInfoDoc.data()['imagePath'] == null) {
        await FirebaseFirestore.instance
            .collection('customerInfo')
            .doc(authUserId)
            .update({'imagePath': ''});
      } else {
        userImage = await sendUserInfoDoc.data()['imagePath'];
      }
      //投稿するユーザーの名前の判別
      if (customerModel.name == '') {
        userName =
            '匿名おひさまさん(${sendUserInfoDoc.data()['uid'].toString().substring(0, 7)})';
      } else {
        userName = customerModel.name;
      }
      print('previous post image');
      DocumentReference sentComment, sentRoomComment;
      if (isPersonalRoom) {
        sentRoomComment = await sendRoomComment.add({
          'userUid': authUserId,
          'name': userName,
          'context': content,
          'imagePath': userImage,
          'createAt': Timestamp.now(),
          'postImage': postImage,
          'token': sendUserInfoDoc.data()['token']
        });
      } else {
        sentComment = await sendComment.add({
          'userUid': authUserId,
          'name': userName,
          'context': content,
          'like': 0,
          'imagePath': userImage,
          'createAt': Timestamp.now(),
          'postImage': postImage,
          'returnName': null,
          'returnUserUid': '',
          'token': sendUserInfoDoc.data()['token']
        });
      }

      print('done add doc');

      //TODO docの部分をどうするか考える（手前に持ってきてグローバル変数としてstrを持たせるのが得策とかんがえる）
      print('previous send _image = $_image');
      if (_image != null) {
        print('start send image');
        var task = await firebase_storage.FirebaseStorage.instance
            .ref('chatImages/' + authUserId + '.jpg')
            .putFile(_image);
        print(task.storage);
        if (isPersonalRoom) {
          await task.ref.getDownloadURL().then((downloadURL) =>
              FirebaseFirestore.instance
                  .collection(collection)
                  .doc(widget.messageUid)
                  .collection('roomChats')
                  .doc(sentRoomComment.id)
                  .update({'postImage': downloadURL}));
        } else {
          await task.ref.getDownloadURL().then((downloadURL) =>
              FirebaseFirestore.instance
                  .collection(collection)
                  .doc(sentComment.id)
                  .update({'postImage': downloadURL}));
        }
      } else {
        postImage = '';
      }
      print('end func');
      if (isPersonalRoom) {
        Navigator.pop(context);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeSection()));
      }
      //TODO not push but replacement
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => BoardRoomPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('投稿'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              (widget.customerModel.name == '')
                  ? Text('匿名おひさまさん')
                  : Text(widget.customerModel.name),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (input) {
                  for (var i = 0; i < prohibisionWords.length; i++) {
                    if (input.contains(prohibisionWords[i])) {
                      return '不適切な言葉が含まれています';
                    }
                    if (input.isEmpty) {
                      return '投稿内容を入力してください';
                    }
                  }
                  return null;
                },
                onSaved: (input) => content = input,
                decoration: const InputDecoration(labelText: '投稿内容'),
              ),
              const SizedBox(height: 15),
              (_image != null) ? Image.file(_image) : const SizedBox(),
              const SizedBox(height: 15),
              FlatButton(
                onPressed: () {
                  getImageFromGallery();
                },
                child: Material(
                    elevation: 4,
                    shadowColor: Colors.grey,
                    color: Color(0xff7cc8e9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: SizedBox(
                      height: 35,
                      child: Center(
                        child: const Text(
                          '画像を選択',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 0.8),
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '投稿すると',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    TextSpan(
                      text: '利用規約',
                      style: TextStyle(color: Colors.lightBlue),
                      recognizer: _recognizer,
                    ),
                    TextSpan(
                      text: 'に同意したものとみなします。',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル')),
        FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                // TextFormFieldのonSavedが呼び出される
                _formKey.currentState.save();
                if (widget.messageUid == null) {
                  await addComment(
                      widget.collection, widget.customerModel, false);
                } else {
                  await addComment(
                      widget.collection, widget.customerModel, true);
                }
                print('pass onPressed');
              }
            },
            child: const Text('投稿'))
      ],
    );
  }
}
