import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainModel extends ChangeNotifier {
  List allHinataBlog = [];

  fetchHinataBlog() async {
    var ref =
        FirebaseStorage.instance.ref().child('blog/oneYearHinataBlog.json');
    String url = (await ref.getDownloadURL()).toString();

    final response = await http.get(url);
    var listData = jsonDecode(utf8.decode(response.body.runes.toList()));

    for (int i = 0; i < listData.length; i++) {
      var blogDict = {};
      blogDict['title'] = listData[i.toString()]['title'];
      blogDict['name'] = listData[i.toString()]['name'];
      blogDict['date'] = listData[i.toString()]['date'].substring(
          0, ((listData[i.toString()]['date']).toString()).length - 5);
      blogDict['image'] = listData[i.toString()]['image0'];
      for (int x = 0; x < listData[i.toString()].length - 5; x++) {
        var listIndex = 1 + x;
        var xIndex = 2 + x;
        blogDict['image$xIndex'] = listData[i.toString()]['image$listIndex'];
      }
      blogDict['href'] = listData[i.toString()]['href'];
      allHinataBlog.add(blogDict);
    }
    notifyListeners();
  }
}
