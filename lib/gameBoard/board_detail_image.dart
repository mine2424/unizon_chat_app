import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class BoardDetailsImage extends StatelessWidget {
  var image;
  BoardDetailsImage({Key key, this.image}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Positioned(
              top: 20,
              child: FlatButton(
                hoverColor: Colors.white,
                onPressed: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                child: PhotoView(
                  enableRotation: true,
                  maxScale: PhotoViewComputedScale.covered * 3.5,
                  imageProvider: NetworkImage(image),
                ),
              ),
            ),
          ],
        ),
      ),
      // body: SingleChildScrollView(
      //   child: Stack(
      //     children: [
      //       Positioned(
      //         left: 20,
      //         top: 20,
      //         child: Container(
      //           padding: const EdgeInsets.all(8.0),
      //           child: FlatButton(
      //             onPressed: () => Navigator.pop(context),
      //             child: Icon(Icons.arrow_back, color: Colors.white),
      //           ),
      //         ),
      //       ),
      //       Hero(
      //         tag: image.toString(),
      //         child: Center(
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [Image.network(image)],
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
