// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unizon_chat_app/models/mainModels.dart';

import 'blogWebview.dart';

class PersonalBlogPage extends StatefulWidget {
  var profile, allHinataBlog;
  PersonalBlogPage(
      {Key key, @required this.profile, @required this.allHinataBlog})
      : super(key: key);

  @override
  _PersonalBlogPageState createState() => _PersonalBlogPageState();
}

class _PersonalBlogPageState extends State<PersonalBlogPage> {
  List sortBlogData = [];

  initState() {
    for (int i = 0; i < widget.allHinataBlog.length; i++) {
      if (widget.profile["name"] == widget.allHinataBlog[i]["name"]) {
        sortBlogData.add(widget.allHinataBlog[i]);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel()..fetchHinataBlog(),
        child: Consumer<MainModel>(builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF21BFBD),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 45, left: 15),
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.arrow_back_outlined),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        Text(
                          widget.profile["name"],
                          style: const TextStyle(
                              fontSize: 26,
                              fontFamily: "SF-Pro-Text-Regular",
                              color: Colors.white),
                        ),
                        const SizedBox(width: 60),
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(widget.profile["image"]),
                              )),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height, //-185
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(40))),
                    child: ListView.builder(
                      key: GlobalKey(),
                      primary: false,
                      itemCount: sortBlogData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, top: 20),
                          child: FlatButton(
                              onPressed: () => setState(() {
                                    if (sortBlogData[index]['href'] != "") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BlogWebView(
                                                  blogData:
                                                      sortBlogData[index])));
                                    }
                                  }),
                              child: Column(
                                children: [
                                  (sortBlogData[index]["image"] == "" ||
                                          sortBlogData[index]["image"] == null)
                                      ? Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      'https://www.hinatazaka46.com/files/14/hinata/img/noimage_blog.jpg'))),
                                        )
                                      : Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      sortBlogData[index]
                                                          ["image"]))),
                                        ),
                                  ListTile(
                                    title: Text(
                                      sortBlogData[index]['title'],
                                    ),
                                    subtitle: Text(
                                        sortBlogData[index]['date'].toString()),
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }));
  }
}
