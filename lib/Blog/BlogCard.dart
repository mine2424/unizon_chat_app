import 'package:flutter/material.dart';

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

// ignore: must_be_immutable
class BlogCardWidget extends StatelessWidget {
  var allHinataBlog;
  BlogCardWidget({Key key, @required this.allHinataBlog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12, offset: Offset(3.0, 6.0), blurRadius: 10.0)
        ]),
        child: AspectRatio(
          aspectRatio: cardAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              (allHinataBlog["image"] == "" || allHinataBlog["image"] == null)
                  ? Image.network(
                      "https://www.hinatazaka46.com/files/14/hinata/img/noimage_blog.jpg",
                      fit: BoxFit.cover,
                    )
                  : Image.network(allHinataBlog["image"], fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: (allHinataBlog["image"] == "" ||
                              allHinataBlog["image"] == null)
                          ? Text(
                              (allHinataBlog['title']).toString() +
                                  ' | ' +
                                  allHinataBlog['name'],
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontFamily: "SF-Pro-Text-Regular"))
                          : Text((allHinataBlog['title']).toString(),
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontFamily: "SF-Pro-Text-Regular")),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 6.0),
                        // decoration: BoxDecoration(
                        //     color: Colors.blueAccent,
                        //     borderRadius: BorderRadius.circular(20.0)),
                        // child: Text("あとで読む",
                        //     style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
