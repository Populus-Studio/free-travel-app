import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipecards/flutter_swipecards.dart';
// import 'package:flutter_tindercard/flutter_tindercard.dart'; // This does not support Null Safety
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

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
  late final h = MediaQuery.of(context).size.height;
  late final w = MediaQuery.of(context).size.width;
  late final rh = h / Utils.h13pm;
  late final rw = w / Utils.w13pm;

  @override
  Widget build(BuildContext context) {
    late var controller;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('选择你想去的地点'),
          // backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          // Wrap TinderSwapCard in Padding otherwise the animation is weird.
          padding: EdgeInsets.only(bottom: 120.0 * rh),
          child: FutureBuilder<List<Location>>(
            // SET LISTEN TO FALSE!! Because otherwize this FutureBuilder is
            // going to be rebuilt every time notifyListeners() is called during
            // fetching, causing endless rebuilding of the builder and thus
            // endless fetching of random locations!
            future: Provider.of<Locations>(context, listen: false)
                .recommendedLocations,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final locations = snapshot.data as List<Location>;
                final len = locations.length;
                return TinderSwapCard(
                  totalNum: len,
                  maxWidth: w,
                  maxHeight: h * 0.75,
                  minWidth: w * 0.75,
                  minHeight: h * 0.6,
                  cardBuilder: (context, index) => ChangeNotifierProvider.value(
                    value: locations[index],
                    child: LargeCard(h * 0.75, rw, key: UniqueKey()),
                  ),
                  cardController: controller =
                      CardController(), // This triggers swipe without swiping.
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
                      Utils.showMaterialAlertDialog(
                              context, '选完啦！', const Text('你已经完成选择，轻触OK返回'))
                          .then((_) {
                        Navigator.of(context).pop();
                      });
                    } else {
                      HapticFeedback.selectionClick();
                      // Vibration.vibrate();
                      if (orientation == CardSwipeOrientation.left) {
                        // TODO: Swiped to the left
                      } else if (orientation == CardSwipeOrientation.right) {
                        // TODO: Swiped to the right
                      }
                    }
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
            },
          ),
        ));
  }
}
