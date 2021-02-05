import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unizon_chat_app/common/color/color.dart';
import 'package:unizon_chat_app/homeSection.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _callName, _callMail, _callContext;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせフォーム'),
        backgroundColor: mainPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('お名前', style: TextStyle(fontSize: 20)),
                      TextFormField(
                        maxLength: 50,
                        maxLines: 1,
                        onSaved: (input) => _callName = input,
                      ),
                      const SizedBox(height: 20),
                      const Text('メールアドレス', style: TextStyle(fontSize: 20)),
                      TextFormField(
                        maxLength: 50,
                        maxLines: 1,
                        onSaved: (input) => _callMail = input,
                      ),
                      const SizedBox(height: 20),
                      const Text('ご用件', style: TextStyle(fontSize: 20)),
                      TextFormField(
                        maxLength: 100,
                        maxLines: 1,
                        onSaved: (input) => _callContext = input,
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        width: 200,
                        height: 46,
                        child: RaisedButton(
                          child: const Text("送信",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          color: mainPurple,
                          shape: const StadiumBorder(),
                          onPressed: () {
                            addFormList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> addFormList() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      //login and describe user details to firebase
      try {
        if (_callName == "" || _callMail == "" || _callContext == "") {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('注意'),
                    content: const Text('記入漏れがあります'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.of(context).pop(0),
                      ),
                    ]);
              });
        } else {
          FirebaseFirestore.instance.collection('usersContactForm').add({
            'createAt': Timestamp.now(),
            'email': _callMail,
            'text': _callContext,
            'uid': FirebaseAuth.instance.currentUser.uid
          });
          return Navigator.push(
              context, MaterialPageRoute(builder: (context) => FormFinish()));
        }
      } catch (error) {
        print(error);
      }
    }
  }
}

class FormFinish extends StatefulWidget {
  @override
  _FormFinishState createState() => _FormFinishState();
}

class _FormFinishState extends State<FormFinish> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeSection()));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '送信が完了しました！',
              style: TextStyle(fontSize: 20),
            ),
            const Text(
              '3秒ほどでホームに戻ります',
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
