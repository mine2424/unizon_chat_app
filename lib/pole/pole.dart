import 'package:flutter/material.dart';
import 'package:unizon_chat_app/homeSection.dart';

class PolePage extends StatefulWidget {
  @override
  _PolePageState createState() => _PolePageState();
}

final _formKey = GlobalKey<FormState>();
String formContent, formMostUsed;

class _PolePageState extends State<PolePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("アンケートのお願い", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 16, right: 4),
                  child: Text(
                    '・このアプリに欲しい機能等をお書きください',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'テキストを入力してください。';
                    }
                    return null;
                  },
                  onSaved: (input) {
                    formContent = input;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.receipt,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white30),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 16, right: 4),
                  child: Text(
                    '・このアプリで一番使っている機能をお書きください',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'テキストを入力してください。';
                    }
                    return null;
                  },
                  onSaved: (input) {
                    formMostUsed = input;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white30),
                ),
                const SizedBox(height: 40),
                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      await _sendFormResult();
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => HomeSection(),
                        ),
                      );
                    }
                  },
                  color: Color(0xff7cc8e9),
                  child: Text(
                    '送信する',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendFormResult() async {
    // final uid = FirebaseAuth.instance.currentUser.uid;
    // await FirebaseFirestore.instance.collection('usersContactForm').add({
    //   'formContent': formContent,
    //   'formMostUsed': formMostUsed,
    //   'createAt': Timestamp.now(),
    //   'uid': uid
    // });
    // await FirebaseFirestore.instance
    //     .collection('customerInfo')
    //     .doc(uid)
    //     .update({'twitter': 'FirstPoleIsDone'});
  }
}
