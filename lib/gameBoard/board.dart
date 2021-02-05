import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share/share.dart';
import 'package:unizon_chat_app/common/color/color.dart';
import 'package:unizon_chat_app/common/constant/auth.dart';
import 'package:unizon_chat_app/gameBoard/board_detail_image.dart';
import 'package:unizon_chat_app/gameBoard/board_user_info.dart';
import 'package:unizon_chat_app/homeSection.dart';
import 'package:unizon_chat_app/prohibitionMatter/prohibitionWord.dart';
import 'package:unizon_chat_app/setting/setting.dart';
import 'package:url_launcher/url_launcher.dart';

import 'board_room.dart';
import 'bottomAddCommentButton.dart';

// ignore: must_be_immutable
class BoardPage extends StatefulWidget {
  @override
  BoardPageState createState() => BoardPageState();
}

List chatsList = [];
String content, postImage;
bool isLike = true;
File _image2;
final picker = ImagePicker();
var _messageCautionsList = ['ブロック', '報告', '削除'];
//TODO シングルトン化してコードの省略
// final authUserId
var chatLength, customerImagePath;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class BoardPageState extends State<BoardPage> {
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
    return Scaffold(
      floatingActionButton: BottomAddCommentButton(
          collection: 'friendChats', chatLength: chatLength, sendUser: ''),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friendChats')
            .orderBy('createAt', descending: true)
            .limit(160)
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
              : (snapshot.data.docs.length == 0)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/UNI\'S ON AIR CHAT.png',
                              scale: 1.4),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2)
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
                        return (chatsItem.data()['name'] == '運営')
                            ? commentBox(chatsItem, createdTime, 'admin', index)
                            : commentBox(chatsItem, createdTime, '', index);
                      },
                    );
        },
      ),
    );
  }

  Widget commentBox(
      QueryDocumentSnapshot chatsItem, createdTime, isAdmin, int heroCount) {
    final likeDoc = FirebaseFirestore.instance
        .collection('friendChats')
        .doc(chatsItem.id.toString());

    final userDoc =
        FirebaseFirestore.instance.collection('customerInfo').doc(authUserId);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: FlatButton(
            minWidth: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BoardUserInfoPage(userUid: chatsItem.data()['userUid']),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.16,
              height: MediaQuery.of(context).size.width * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: (chatsItem.data()['imagePath'] == null ||
                          chatsItem.data()['imagePath'] == '')
                      ? AssetImage('assets/images/UNI\'S ON AIR CHAT.png')
                      : NetworkImage(
                          chatsItem.data()['imagePath'],
                        ),
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
                    : (chatsItem.data()['returnName'] != null)
                        ? mainBlue
                        : mainPurple,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatsItem.data()['name'],
                        style: TextStyle(
                            color: white,
                            fontSize: 13.2,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.52,
                        child: (chatsItem.data()['returnName'] != null)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@' + chatsItem.data()['returnName'],
                                    style: const TextStyle(
                                      color: white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  _selectableTextContent(chatsItem),
                                ],
                              )
                            : _selectableTextContent(chatsItem),
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
                            style: const TextStyle(
                              color: white,
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
                                      height: 180,
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
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                IconButton(
                    padding: EdgeInsets.all(4.0),
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.thumb_up,
                      size: 24,
                    ),
                    color: Colors.grey,
                    onPressed: () async {
                      final fetchLike = await likeDoc.get();
                      final fetchUserlike = await userDoc.get();
                      likeDoc.update({
                        'like': fetchLike.data()['like'] + 1,
                        'isLike': false
                      });
                      userDoc
                          .update({'like': fetchUserlike.data()['like'] + 1});
                      setState(() {
                        isLike = false;
                      });
                    }),
                Text(
                  chatsItem.data()['like'].toString(),
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12.2,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '返信',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12.2,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.reply,
                    size: 20,
                  ),
                  color: Colors.grey,
                  onPressed: () {
                    var yourName = chatsItem.data()['name'];
                    showDialog<void>(
                      context: context,
                      builder: (_) => ReplyDialogWidget(
                        myName: yourName,
                        chatsItem: chatsItem,
                      ),
                    );
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (BuildContext context) => BoardRoomPage(
                    //       yourName: yourName,
                    //       messageUid: chatsItem.id,
                    //       thisMessage: chatsItem,
                    //     ),
                    //   ),
                    // );
                  },
                ),
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: PopupMenuButton<String>(
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
          ),
        ),
      ],
    );
  }

  Future removeComment(String nowComment) async {
    await FirebaseFirestore.instance
        .collection('friendChats')
        .doc(nowComment)
        .delete();
    return Navigator.pop(context);
  }

  Widget _selectableTextContent(chatsItem) {
    return SelectableAutoLinkText(
      chatsItem.data()['context'],
      style: const TextStyle(
        color: white,
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
  ReplyDialogWidget({Key key, this.myName, this.chatsItem}) : super(key: key);
  String myName;
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

  Future<void> replyComment(collection, replyInfo) async {
    if (_formKey.currentState.validate()) {
      String userName, userImage = '';
      _formKey.currentState.save();
      // 各boardのcollectionを取得
      final sendComment = FirebaseFirestore.instance.collection(collection);
      // 各Userで画像を取得
      final sendUserInfoDoc = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(authUserId)
          .get();

      if (sendUserInfoDoc.data()['imagePath'] == null) {
        await FirebaseFirestore.instance
            .collection('customerInfo')
            .doc(authUserId)
            .update({'imagePath': ''});
      } else {
        userImage = await sendUserInfoDoc.data()['imagePath'];
      }

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
        'like': 0,
        'imagePath': userImage,
        'createAt': Timestamp.now(),
        'returnName': replyInfo['name'],
        'returnUserUid': replyInfo['userUid'],
        'postImage': null,
        'token': sendUserInfoDoc.data()['token']
      });
      print(sendUserInfoDoc.data()['token']);

      //TODO docの部分をどうするか考える（手前に持ってきてグローバル変数としてstrを持たせるのが得策とかんがえる）
      if (_image2 != null) {
        print('_image2 exist');
        var task = await firebase_storage.FirebaseStorage.instance
            .ref('chatImages/' + authUserId + '.jpg')
            .putFile(_image2);
        await task.ref.getDownloadURL().then((downloadURL) => FirebaseFirestore
            .instance
            .collection(collection)
            .doc(sentComment.id)
            .update({'postImage': downloadURL}));
      } else {
        postImage = '';
      }
      print('end func');

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeSection()));
    }
  }

  @override
  void dispose() {
    super.dispose();
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
              await replyComment('friendChats', widget.chatsItem.data());
            }
          },
          child: const Text('返信'),
        ),
      ],
    );
  }
}
