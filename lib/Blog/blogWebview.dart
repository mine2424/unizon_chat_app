import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class BlogWebView extends StatefulWidget {
  var blogData;
  BlogWebView({Key key, @required this.blogData}) : super(key: key);
  @override
  _BlogWebViewState createState() => _BlogWebViewState();
}

class _BlogWebViewState extends State<BlogWebView> {
  List<String> _imageSelects = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i < widget.blogData.length - 3; i++) {
      if (i == 1) {
        _imageSelects.add(widget.blogData['image']);
      } else {
        _imageSelects.add(widget.blogData['image$i']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey(),
      appBar: AppBar(
        title: const Text('ひなこいチャット', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            key: GlobalKey(),
            itemBuilder: (BuildContext context) {
              count = 0;
              return _imageSelects.map((s) {
                count += 1;
                return PopupMenuItem(
                  key: GlobalKey(),
                  child: (s == null)
                      ? const Text('画像がありません')
                      : FlatButton(
                          onPressed: () {
                            saveImage(s);
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: const Text("画像を保存しました"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text("OK"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Image(
                                  image: NetworkImage(s),
                                  fit: BoxFit.cover,
                                  height: 46),
                              const SizedBox(width: 10),
                              Text('画像$count'),
                            ],
                          )),
                  value: s,
                );
              }).toList();
            },
          )
        ],
      ),
      body: WebView(
        key: GlobalKey(),
        initialUrl: widget.blogData["href"],
      ),
    );
  }

  void saveImage(url) async {
    var response = await http.get(url);
    var filePath =
        await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
    var savedFile = File.fromUri(Uri.file(filePath));
    print(savedFile);
  }
}
