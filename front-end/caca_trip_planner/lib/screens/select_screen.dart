import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipecards/flutter_swipecards.dart';
// import 'package:flutter_tindercard/flutter_tindercard.dart'; // This does not support Null Safety
import 'package:provider/provider.dart';

import '../widgets/large_card.dart';
import '../utils.dart';
import '../providers/locations.dart';
import '../providers/location.dart';

class SelectScreen extends StatefulWidget {
  static const routeName = '/select-screen';
  const SelectScreen({Key? key}) : super(key: key);

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;
    final locations =
        Provider.of<Locations>(context, listen: false).recommendedLocations;
    var len = locations.length;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('选择你想去的地点'),
          // backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(bottom: 40 * rh),
          child: TinderSwapCard(
            // FIXME: Animation is weird.
            totalNum: len,
            maxWidth: w,
            maxHeight: h * 0.75,
            minWidth: w * 0.75,
            minHeight: h * 0.5,
            cardBuilder: (context, index) => ChangeNotifierProvider.value(
              value: locations[index],
              child: LargeCard(h * 0.75, rw, key: UniqueKey()),
            ),
            // cardController:
            // CardController(), // This triggers swipe without swiping.
            swipeUpdateCallback:
                (DragUpdateDetails details, Alignment alignment) {
              if (alignment.x < 0) {
                // TODO: left swiping
              } else if (alignment.x > 0) {
                // TODO: right swiping
              }
            },
            swipeCompleteCallback:
                (CardSwipeOrientation orientation, int index) {
              if (index == (locations.length - 1)) {
                // TODO: This is the last card! Probably need to call setState() here.
                // If not, make this screen a stateless widget.
                setState(() {
                  len = locations.length;
                });
              } else {
                if (orientation == CardSwipeOrientation.left) {
                  // TODO: Swiped to the left
                } else if (orientation == CardSwipeOrientation.right) {
                  // TODO: Swiped to the right
                }
              }
            },
          ),
        ));
  }
}
