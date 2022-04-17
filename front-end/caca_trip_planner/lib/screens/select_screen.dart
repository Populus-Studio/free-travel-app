import 'package:cacatripplanner/helpers/futuristic.dart';
import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipecards/flutter_swipecards.dart';
// import 'package:flutter_tindercard/flutter_tindercard.dart'; // This does not support Null Safety
import 'package:provider/provider.dart';
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
  late final Future<List<Location>> _future;
  final List<String> _selectedLocationIds = [];
  final List<String> _discardedLocationIds = [];

  @override
  void initState() {
    _future = Provider.of<Locations>(context, listen: false)
        .recommendedLocations
        .catchError((e) {
      Utils.showMaterialAlertDialog(
        context,
        '获取推荐地点失败',
        Text('错误信息：' + e.toString() + '\n请重新登陆后再试'),
      ).then((_) {
        Navigator.of(context).pop();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late var controller;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: FutureBuilder<List<Location>>(
          future: _future,
          builder: (context, snapshot) => snapshot.hasData
              ? Text(
                  '选择你想去的地点（${_selectedLocationIds.length + _discardedLocationIds.length + 1}/${(snapshot.data as List).length}）')
              : const Text('选择你想去的地点'),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              // Wrap TinderSwapCard in Padding otherwise the animation is weird.
              padding: EdgeInsets.only(bottom: 120.0 * rh),
              child: FutureBuilder<List<Location>>(
                future: _future,
                // NEVER INVOKE FUTURE METHODS IN build()!! Because otherwize this
                // method will get invoked way too many times resulting in
                // significant performance issue! Use initState() instead of
                // the following:
                // future: Provider.of<Locations>(context, listen: false)
                //     .recommendedLocations
                //     .catchError((e) {
                //   Utils.showMaterialAlertDialog(
                //     context,
                //     '获取推荐地点失败',
                //     Text('错误信息：' + e.toString() + '\n请重新登陆后再试'),
                //   ).then((_) {
                //     Navigator.of(context).pop();
                //   });
                // }),
                // future: Provider.of<Locations>(context, listen: false)
                //     .recommendedLocations,
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
                      cardBuilder: (context, index) =>
                          ChangeNotifierProvider.value(
                        value: locations[index],
                        child: LargeCard(
                          h * 0.81,
                          rw,
                          w: w,
                          key: UniqueKey(),
                        ),
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
                        // maybe show some tips if the user has been dragging for too long
                      },
                      swipeCompleteCallback:
                          (CardSwipeOrientation orientation, int index) {
                        if (orientation == CardSwipeOrientation.left ||
                            orientation == CardSwipeOrientation.right) {
                          print('swipe completed!');
                          if (index == (locations.length - 1)) {
                            // TODO: This is the last card! Probably need to call setState() here.
                            // If not, make this screen a stateless widget.
                            Utils.showMaterialAlertDialog(context, '选完啦！',
                                    const Text('你已经完成选择，轻触OK返回'))
                                .then((_) {
                              Navigator.of(context).pop();
                            });
                          } else {
                            HapticFeedback.selectionClick();
                            if (orientation == CardSwipeOrientation.left) {
                              // TODO: Swiped to the left
                              Utils.postUserBehavior(
                                siteId: locations[index].id,
                                selected: true,
                              );
                              setState(() {
                                _discardedLocationIds.add(locations[index].id);
                              });
                            } else if (orientation ==
                                CardSwipeOrientation.right) {
                              // TODO: Swiped to the right
                              Utils.postUserBehavior(
                                siteId: locations[index].id,
                                selected: false,
                              );
                              setState(() {
                                _selectedLocationIds.add(locations[index].id);
                              });
                            }
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
            ),
          ),
        ],
      ),
    );
  }
}

// Example of using Futuristic
// child: Futuristic<List<Location>>(
        //   futureBuilder: () => Provider.of<Locations>(context, listen: false)
        //       .recommendedLocations,
        //   dataBuilder: (context, locations) {
        //     final len = locations?.length;
        //     return TinderSwapCard(
        //       totalNum: len ?? 0,
        //       maxWidth: w,
        //       maxHeight: h * 0.75,
        //       minWidth: w * 0.75,
        //       minHeight: h * 0.6,
        //       cardBuilder: (context, index) => ChangeNotifierProvider.value(
        //         value: locations?[index],
        //         child: LargeCard(h * 0.75, rw, key: UniqueKey()),
        //       ),
        //       cardController: controller =
        //           CardController(), // This triggers swipe without swiping.
        //       swipeUpdateCallback:
        //           (DragUpdateDetails details, Alignment alignment) {
        //         if (alignment.x < 0) {
        //           // TODO: left swiping
        //         } else if (alignment.x > 0) {
        //           // TODO: right swiping
        //         }
        //       },
        //       swipeCompleteCallback:
        //           (CardSwipeOrientation orientation, int index) {
        //         if (index == (locations?.length ?? 1 - 1)) {
        //           // TODO: This is the last card! Probably need to call setState() here.
        //           // If not, make this screen a stateless widget.
        //           Utils.showMaterialAlertDialog(
        //                   context, '选完啦！', const Text('你已经完成选择，轻触OK返回'))
        //               .then((_) {
        //             Navigator.of(context).pop();
        //           });
        //         } else {
        //           HapticFeedback.selectionClick();
        //           if (orientation == CardSwipeOrientation.left) {
        //             // TODO: Swiped to the left
        //           } else if (orientation == CardSwipeOrientation.right) {
        //             // TODO: Swiped to the right
        //           }
        //         }
        //       },
        //     );
        //   },
        //   initialBuilder: (p0, p1) => const CircularProgressIndicator(),
        // ),
