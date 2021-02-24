import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unizon_chat_app/common/color/color.dart';
import 'package:unizon_chat_app/homeSection.dart';
import 'package:unizon_chat_app/prohibitionMatter/prohibitionWord.dart';

// ignore: must_be_immutable
class ProfileEditPage extends StatefulWidget {
  var costomer;

  ProfileEditPage({
    Key ley,
    @required this.costomer,
  }) : super();
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static String firebaseManagerUid = '7l7ZFl0sDuQw80G77A0RyElFlzS2';
  final _firebaseAuth = FirebaseAuth.instance.currentUser.uid;
  String name, gameId, message;
  File _image;
  final picker = ImagePicker();
  var currentUserInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('ユニゾンチャット'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            painter: HeaderCurvedContainer(),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    _profileText(),
                    _circleAvatar(),
                    _textListCalling(),
                    const SizedBox(height: 500)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileText() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 35.0,
          letterSpacing: 1.5,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _circleAvatar() {
    return Container(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5),
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: _image == null
                  ? (widget.costomer.imagePath != '')
                      ? NetworkImage(widget.costomer.imagePath)
                      : const AssetImage('assets/images/UNI\'S ON AIR CHAT.png')
                  : FileImage(_image)),
        ));
  }

  Widget _textFormField({
    String hintText,
    String myText,
    IconData icon,
  }) {
    return Material(
      elevation: 4,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        validator: (input) {
          if (_firebaseAuth != firebaseManagerUid &&
              (input == '運営' || input == 'うんえい')) {
            return 'その言葉は使用出来ません';
          }
          for (var i = 0; i < prohibisionWords.length; i++) {
            if (input.contains(prohibisionWords[i])) {
              return '不適切な言葉が含まれています';
            }
          }
          return null;
        },
        onSaved: (input) {
          if (hintText == '名前') {
            name = input;
          } else if (hintText == 'ひなこいid') {
            gameId = input;
          } else {
            message = input;
          }
        },
        initialValue: myText,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            prefixIcon: Icon(
              icon,
              color: mainPurple,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              letterSpacing: 2,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: Colors.white30),
      ),
    );
  }

  Widget _textListCalling() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 30),
            FlatButton(
              onPressed: () {
                getImageFromGallery();
              },
              child: Material(
                  elevation: 4,
                  shadowColor: Colors.grey,
                  color: mainPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: SizedBox(
                    height: 40,
                    child: Center(
                      child: const Text(
                        '画像を選択',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                    ),
                  )),
            ),
            const SizedBox(height: 16),
            _textFormField(
                hintText: '名前',
                myText: widget.costomer.name,
                icon: Icons.ac_unit),
            const SizedBox(height: 16),
            _textFormField(
                hintText: 'ひなこいid',
                myText: widget.costomer.gameId,
                icon: Icons.ac_unit),
            const SizedBox(height: 16),
            _textFormField(
                hintText: 'メッセージ',
                myText: widget.costomer.message,
                icon: Icons.ac_unit),
            const SizedBox(height: 16),
            Container(
              height: 55,
              width: double.infinity,
              child: RaisedButton(
                color: mainPurple,
                child: Center(
                  child: const Text(
                    '更新',
                    style: TextStyle(
                        fontSize: 23, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
                onPressed: () {
                  editConsumerInfo();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editConsumerInfo() async {
    try {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        FirebaseFirestore.instance
            .collection('customerInfo')
            .doc(widget.costomer.uid)
            .set({
          'uid': widget.costomer.uid,
          'createAt': widget.costomer.createAt,
          'like': widget.costomer.like,
          'twitter': widget.costomer.twitter,
          'gameId': gameId,
          'insta': name,
          'message': message,
          'imagePath': widget.costomer.imagePath
        });

        if (_image != null) {
          var task = await firebase_storage.FirebaseStorage.instance
              .ref('images/' + widget.costomer.uid + '.jpg')
              .putFile(_image);
          task.ref.getDownloadURL().then((downloadURL) => FirebaseFirestore
              .instance
              .collection('customerInfo')
              .doc(widget.costomer.uid)
              .update({'imagePath': downloadURL}));
          currentUserInfo = FirebaseFirestore.instance
              .collection('customerInfo')
              .doc(_firebaseAuth)
              .get();
          final boardCollectionDi = await FirebaseFirestore.instance
              .collection('discussionChats')
              .get();
          final boardCollectionFr =
              await FirebaseFirestore.instance.collection('friendChats').get();
          final boardCollectionOt =
              await FirebaseFirestore.instance.collection('otherChats').get();
          adjustBoardUserImage(boardCollectionDi);
          adjustBoardUserImage(boardCollectionFr);
          adjustBoardUserImage(boardCollectionOt);
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeSection()));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> adjustBoardUserImage(collection) async {
    for (var i = 0; i < collection.docs.length; i++) {
      if (collection.docs[i].data()['userUid'] == _firebaseAuth) {
        collection.docs[i]
            .update({'imagePath': currentUserInfo.data()['imagePath']});
      }
    }
  }

  Future getImageFromGallery() async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 60);

    setState(() {
      _image = File(pickedFile.path);
    });
  }
}

//Color(0xff555555)
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = mainPurple;
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 250.0, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
