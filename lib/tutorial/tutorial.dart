import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tutorialpage extends StatefulWidget {
  @override
  _TutorialpageState createState() => _TutorialpageState();
}

class _TutorialpageState extends State<Tutorialpage> {
  List<Widget> _pageItems;
  List<String> imageItems = [
    'assets/images/hinata-tutorial-image-0.png',
    'assets/images/hinata-tutorial-image-1.png',
    'assets/images/hinata-tutorial-image-2.png',
    'assets/images/hinata-tutorial-image-3.png'
  ];
  final _controller = PageController();

  @override
  void initState() {
    super.initState();
    _pageItems = [];
    for (int i = 0; i < 4; i++) {
      Widget item = Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Image.asset(
            imageItems[i],
            fit: BoxFit.cover,
          ),
        ),
      );
      _pageItems.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    double pageHeight = MediaQuery.of(context).size.height * 0.6;
    double buttonHeight = MediaQuery.of(context).size.height * 0.1;
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Container(
          height: pageHeight,
          child: PageView(
            children: _pageItems,
            controller: _controller,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        ButtonTheme(
          height: buttonHeight,
          minWidth: 200,
          child: SizedBox(
            height: 30,
            width: 100,
            child: FlatButton(
              shape: const StadiumBorder(),
              color: const Color(0xff7cc8e9),
              onPressed: () async {
                final preference = await SharedPreferences.getInstance();
                preference.setBool('isFirstLaunch', true);
                Navigator.of(context).pop();
              },
              child: const Text(
                "閉じる",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: DotsIndicator(
              controller: _controller,
              itemCount: _pageItems.length,
              color: Colors.grey,
              selectedColor: const Color(0xff7cc8e9),
              onPageSelected: (_) {},
            ),
          ),
        )
      ],
    );
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.grey,
    this.selectedColor: Colors.blue,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;
  final Color selectedColor;
  static const double _kDotSize = 10.0;
  static const double _kDotSpacing = 20.0;

  Widget _buildDot(int index) {
    var displayedIndex = controller.page ?? controller.initialPage;

    return Container(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: (index == displayedIndex) ? selectedColor : color,
          type: MaterialType.circle,
          child: Container(
            width: _kDotSize,
            height: _kDotSize,
            child: InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
