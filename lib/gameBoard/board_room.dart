import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share/share.dart';
import 'package:unizon_chat_app/common/constant/auth.dart';
import 'package:unizon_chat_app/gameBoard/board_detail_image.dart';
import 'package:unizon_chat_app/gameBoard/bottomAddCommentButton.dart';
import 'package:unizon_chat_app/prohibitionMatter/prohibitionWord.dart';
import 'package:unizon_chat_app/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'board_user_info.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BoardRoomPage extends StatefulWidget {
  BoardRoomPage({
    Key key,
    this.yourName,
    this.messageUid,
    this.thisMessage,
  }) : super(key: key);
  final String yourName, messageUid;
  QueryDocumentSnapshot thisMessage;
  @override
  BoardRoomPageState createState() => BoardRoomPageState();
}

List chatsList = [];
String content, postImage;
File _image2;
final picker = ImagePicker();
var _messageCautionsList = ['ブロック', '報告', '削除'];
var chatLength, customerImagePath;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class BoardRoomPageState extends State<BoardRoomPage> {
  //外部URLへページ遷移(webviewではない)
  Future<void> _launchURL(String link) async {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime thisMessageDate = widget.thisMessage.data()['createAt'].toDate();
    return Scaffold(
      appBar: AppBar(
        title: Text('返信', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
      ),
      floatingActionButton: BottomAddCommentButton(
          collection: 'roomChats',
          chatLength: chatLength,
          sendUser: '',
          messageUid: widget.messageUid),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friendChats')
            .doc(widget.messageUid)
            .collection('roomChats')
            .orderBy('createAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          return (!snapshot.hasData)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Now Loading...',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300))
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final chatsItem = snapshot.data.docs[index];
                    chatLength = snapshot.data.docs.length;
                    DateTime createdTime =
                        chatsItem.data()['createAt'].toDate();

                    return (chatsItem.data()['userUid'] == authUserId)
                        ? commentBox(
                            chatsItem, createdTime, '', index, true, false)
                        : (chatsItem.data()['name'] == '運営')
                            ? commentBox(chatsItem, createdTime, 'admin', index,
                                false, false)
                            : commentBox(chatsItem, createdTime, '', index,
                                false, false);
                  },
                );
        },
      ),
    );
  }

  Widget commentBox(
      QueryDocumentSnapshot chatsItem,
      DateTime createdTime,
      String isAdmin,
      int heroCount,
      bool isMycomment,
      bool isThisFirstComment) {
    return Row(
      mainAxisAlignment:
          (isMycomment) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isMycomment && !isThisFirstComment)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sms_failed_outlined,
              size: 22,
            ),
            itemBuilder: (BuildContext context) {
              return _messageCautionsList.map((String s) {
                return PopupMenuItem(
                  child: FlatButton(
                      onPressed: () {
                        if (s == 'ブロック') {
                          blockDialog(chatsItem);
                        }
                        if (s == '報告') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingPage()));
                        }
                        if (s == '削除' &&
                            authUserId == chatsItem.data()['userUid']) {
                          _rmCommentMyself(chatsItem.id);
                        }
                      },
                      child: (authUserId == chatsItem.data()['userUid'])
                          ? Text(s)
                          : (s == '削除')
                              ? null
                              : Text(s)),
                  value: s,
                );
              }).toList();
            },
          ),
        if (isThisFirstComment) const SizedBox(width: 24),
        (isMycomment || isThisFirstComment)
            ? const SizedBox()
            : FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardUserInfoPage(
                          userUid: chatsItem.data()['userUid']),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.width * 0.12,
                  decoration: (isMycomment)
                      ? BoxDecoration()
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (chatsItem.data()['imagePath'] == null ||
                                    chatsItem.data()['imagePath'] == '')
                                ? AssetImage(
                                    'assets/images/UNI\'S ON AIR CHAT.png')
                                : NetworkImage(
                                    chatsItem.data()['imagePath'],
                                  ),
                          ),
                        ),
                ),
              ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 5, left: 3),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: (isAdmin == 'admin')
                    ? Colors.red[300]
                    : (isMycomment)
                        ? Colors.grey[400]
                        : Color(0xff99FF73),
                borderRadius: (isMycomment)
                    ? BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.52,
                        child: _selectableTextContent(chatsItem),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            createdTime.toLocal().toString().substring(
                                  0,
                                  createdTime.toLocal().toString().length - 10,
                                ),
                            style: TextStyle(
                              color: (isMycomment)
                                  ? Colors.white70
                                  : Colors.blueGrey,
                              fontSize: 11,
                              // fontWeight: FontWeight,
                            ),
                          ),
                        ],
                      ),
                      (chatsItem.data()['postImage'] != null)
                          ? Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BoardDetailsImage(
                                        image: chatsItem.data()['postImage'],
                                      ),
                                    ),
                                  ),
                                  child: Hero(
                                    tag: heroCount.toString(),
                                    child: Image.network(
                                      chatsItem.data()['postImage'],
                                      filterQuality: FilterQuality.medium,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        (!isMycomment)
            ? (isThisFirstComment)
                ? const SizedBox()
                : PopupMenuButton<String>(
                    icon: Icon(
                      Icons.sms_failed_outlined,
                      size: 23,
                    ),
                    itemBuilder: (BuildContext context) {
                      return _messageCautionsList.map((String s) {
                        return PopupMenuItem(
                          child: FlatButton(
                              onPressed: () {
                                if (s == 'ブロック') {
                                  blockDialog(chatsItem);
                                }
                                if (s == '報告') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingPage()));
                                }
                                if (s == '削除' &&
                                    authUserId == chatsItem.data()['userUid']) {
                                  _rmCommentMyself(chatsItem.id);
                                }
                              },
                              child: (authUserId == chatsItem.data()['userUid'])
                                  ? Text(s)
                                  : (s == '削除')
                                      ? null
                                      : Text(s)),
                          value: s,
                        );
                      }).toList();
                    },
                  )
            : const SizedBox(width: 24)
      ],
    );
  }

  Future removeComment(String nowComment) async {
    await FirebaseFirestore.instance
        .collection('friendChats')
        .doc(widget.messageUid)
        .collection('roomChats')
        .doc(nowComment)
        .delete();
    return Navigator.pop(context);
  }

  Widget _selectableTextContent(chatsItem) {
    return SelectableAutoLinkText(
      chatsItem.data()['context'],
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w300,
      ),
      linkStyle: const TextStyle(
        color: Colors.blueAccent,
      ),
      highlightedLinkStyle: TextStyle(
        color: Colors.blueAccent,
        backgroundColor: Colors.blueAccent.withAlpha(0x33),
      ),
      onTap: (url) => _launchURL(url),
      onLongPress: (url) => Share.share(url),
    );
  }

  _rmCommentMyself(nowComment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('本当に削除しますか？(自分の投稿したものしか削除できません)'),
          actions: [
            FlatButton(
              onPressed: () => removeComment(nowComment),
              child: Text('はい'),
            ),
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('いいえ'),
            ),
          ],
        );
      },
    );
  }

  blockDialog(chatsItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('警告'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('本当にブロックしますか?'),
                Text(
                  '不適切と判断した場合のみ',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  '当コメントが削除されます',
                  style: TextStyle(fontSize: 13),
                )
              ],
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('usersContactForm').add(
                  {
                    'uid': authUserId,
                    'cautionUid': chatsItem.data()['userUid'],
                    'cautionContext': chatsItem.data()['context'],
                    'createAt': Timestamp.now(),
                  },
                );
                Navigator.pop(context);
              },
              child: Text('はい'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('いいえ'),
            )
          ],
        );
      },
    );
  }
}

class ReplyDialogWidget extends StatefulWidget {
  ReplyDialogWidget({Key key, this.myName, this.chatsItem, this.messageUid})
      : super(key: key);
  String myName, messageUid;
  var chatsItem;
  @override
  _ReplyDialogWidgetState createState() => _ReplyDialogWidgetState();
}

class _ReplyDialogWidgetState extends State<ReplyDialogWidget> {
  Future<void> getImageFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 60);

    setState(() {
      _image2 = File(pickedFile.path);
    });
  }

  Future<void> retrieveLostData() async {
    LostData response = await picker.getLostData();

    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image2 = File(response.file.toString());
      });
    } else {
      var _retrieveDataError = response.exception.code;
      print('RETRIEVE ERROR: ' + _retrieveDataError);
    }
  }

  TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () {
      launch('https://hinatapicks.web.app/');
    };

  Future<void> replyComment(messageUid, collection, replyInfo) async {
    if (_formKey.currentState.validate()) {
      String userName, userImage = '';
      _formKey.currentState.save();
      // 各boardのcollectionを取得
      final sendComment = FirebaseFirestore.instance
          .collection('friendChats')
          .doc(messageUid)
          .collection('roomChats');
      // 各Userで画像を取得
      final sendUserInfoDoc = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(authUserId)
          .get();

      if (sendUserInfoDoc.data()['insta'] == '') {
        userName =
            '匿名おひさまさん(${sendUserInfoDoc.data()['uid'].toString().substring(0, 7)})';
      } else {
        userName = await sendUserInfoDoc.data()['insta'];
      }

      var sentComment = await sendComment.add({
        'userUid': authUserId,
        'name': userName,
        'context': content,
        'imagePath': userImage,
        'createAt': Timestamp.now(),
        'returnName': replyInfo['name'],
        'returnUserUid': replyInfo['userUid'],
        'postImage': '',
        'token': sendUserInfoDoc.data()['token']
      });

      //TODO docの部分をどうするか考える（手前に持ってきてグローバル変数としてstrを持たせるのが得策とかんがえる）
      if (_image2 != null) {
        print('_image2 exist');
        var task = await firebase_storage.FirebaseStorage.instance
            .ref('chatImages/' + authUserId + '.jpg')
            .putFile(_image2);
        await task.ref.getDownloadURL().then((downloadURL) => FirebaseFirestore
            .instance
            .collection('friendChats')
            .doc(messageUid)
            .collection(collection)
            .doc(sentComment.id)
            .update({'postImage': downloadURL}));
      } else {
        postImage = '';
      }
      print('end func');

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('返信'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(widget.myName + 'に返信'),
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
              (_image2 != null) ? Image.file(_image2) : const SizedBox(),
              const SizedBox(height: 15),
              FlatButton(
                onPressed: () async {
                  await getImageFromGallery();
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
              _formKey.currentState.save();
              await replyComment(
                  widget.messageUid, 'roomChats', widget.chatsItem.data());
            }
          },
          child: const Text('返信'),
        ),
      ],
    );
  }
}
