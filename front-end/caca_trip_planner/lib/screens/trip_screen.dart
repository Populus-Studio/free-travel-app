import 'package:cacatripplanner/helpers/dash_line_separator.dart';
import 'package:cacatripplanner/helpers/hero_dialog_route.dart';
import 'package:cacatripplanner/widgets/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../widgets/large_card.dart';
import '../widgets/trip_summary_card.dart';
import '../providers/location.dart';
import '../providers/trip.dart';
import '../utils.dart';

/// This screen gets tripId from route arguments.
class TripScreen extends StatefulWidget {
  static const routeName = '/trip-screen';
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late final trip = ModalRoute.of(context)?.settings.arguments as Trip;
  late final h = MediaQuery.of(context).size.height;
  late final w = MediaQuery.of(context).size.width;
  late final rh = h / Utils.h13pm;
  late final rw = w / Utils.w13pm;
  late final _appBarExpandedHeight = 240 * rh;
  late final _dayIndicatorHeight = 50 * rh;
  late final _appBarFoldedHeight = 75 * rh;
  late final _safeAreaHeight = MediaQuery.of(context).padding.top;
  late final ScrollController _scrollController;
  late final ScrollController _dayIndicatorController;
  late final _tscHeroTag = 'trip-summary-card-' + trip.id;
  bool _showAppBar = false;
  bool _showCalendarIcon = false;
  int _currentDay = 0;

  /// This field needs to be maintained manually!
  late final _dayIndicatorChipWidth = (80 + 10 * 2) * rw;

  /// This is a lock to prevent two auto scrolling happening at the same time.
  bool _disableAutoScrolling = false;

  // For tracking the TripSummaryCard's size.
  final _tscKey = GlobalKey();

  /// This TripSummaryCard has no hero tag but a key!
  late final tripSummaryCard = TripSummaryCard(trip: trip, key: _tscKey);

  /// TripSummaryCard's height;
  double? _tscHeight;

  /// For tracking the scroll position of the list of activities
  late final List<GlobalKey> _dayLabelKeys =
      List.generate(trip.duration, (index) => GlobalKey());

  /// For making sure day chips in DayIndicator always shows
  late final List<GlobalKey> _dayChipKeys =
      List.generate(trip.duration, (index) => GlobalKey());

  /// Recording the position of the day labels
  late final List<double> _dayLabelPositions;

  /// Scroll (with animation) to a given day in trip
  void _scrollToDay(int day,
      {required bool dayIndicator, required bool list}) async {
    // to avoid conflict
    Future<void>? _future1;
    Future<void>? _future2;
    _disableAutoScrolling = true;

    // scroll DayIndicator
    if (dayIndicator) {
      // calculate scroll distance to avoid overflow
      double scrollDistance = 0;

      /// A screen can fit 4 chips - following calculation improves the scroll
      /// by controlling overflowing, and also making sure the current day is in
      /// the middle.
      if (trip.duration - day > 3) {
        scrollDistance = day * _dayIndicatorChipWidth;
        if (day != 0) scrollDistance -= _dayIndicatorChipWidth;
      } else if (trip.duration >= 4) {
        scrollDistance = (trip.duration - 4) * _dayIndicatorChipWidth;
      }

      // scroll
      _future1 = _dayIndicatorController.animateTo(
        scrollDistance,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      /// The following method also works, but has less customizability.
      // if (_dayChipKeys[day].currentContext != null &&
      //     _dayChipKeys[day].currentContext!.findRenderObject() != null) {
      //   _future1 = _dayIndicatorController.position.ensureVisible(
      //     _dayChipKeys[day].currentContext!.findRenderObject()!,
      //     alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      //     duration: const Duration(milliseconds: 300),
      //     curve: Curves.easeInOut,
      //   );
      // }
    }

    // scroll big list
    if (list) {
      _future2 = _scrollController.animateTo(
        _dayLabelPositions[day],
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // release lock
    if (_future1 != null) await _future1;
    if (_future2 != null) await _future2;
    _disableAutoScrolling = false;
  }

  @override
  void initState() {
    _dayIndicatorController = ScrollController()..addListener(() {});
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_disableAutoScrolling) {
          // 1 - moving on to the next day
          bool detected = false;
          for (int i = 0; i < trip.duration; i++) {
            if (_dayLabelKeys[i].currentContext != null) {
              final topPos = _dayLabelKeys[i].globalPaintBounds!.top;
              if ((topPos -
                          _safeAreaHeight -
                          _appBarFoldedHeight -
                          _dayIndicatorHeight)
                      .abs() <
                  20) {
                setState(() {
                  _currentDay = i;
                  _scrollToDay(i, dayIndicator: true, list: false);
                });
                detected = true;
                break;
              }
            }
          }
          // 2 - moving back to the previous day
          if (!detected) {
            // i > 0 to exclude the first day
            for (int i = trip.duration - 1; i > 0; i--) {
              if (_dayLabelKeys[i].currentContext != null) {
                final bottomPos = _dayLabelKeys[i].globalPaintBounds!.bottom;
                if ((bottomPos - h * 0.8).abs() < 20) {
                  setState(() {
                    _currentDay = i - 1;
                    _scrollToDay(_currentDay, dayIndicator: true, list: false);
                  });
                  break;
                }
              }
            }
          }
        }

        // determine if title should show based on current scroll position
        final isNotExpanded = _scrollController.hasClients &&
            _scrollController.offset > _appBarExpandedHeight - kToolbarHeight;

        // Find TripSummaryCard's position.
        late final bool summaryIsHidden;
        if (_tscKey.currentContext != null) {
          // tiny name clash with line 65 but whatever...
          final bottomPos = _tscKey.globalPaintBounds!.bottom;
          summaryIsHidden =
              (bottomPos - _safeAreaHeight - _appBarFoldedHeight) < 0;
        } else {
          summaryIsHidden = false;
        }

        if (isNotExpanded != _showAppBar) {
          setState(() {
            _showAppBar = isNotExpanded;
          });
        }
        if (summaryIsHidden != _showCalendarIcon) {
          setState(() {
            _showCalendarIcon = summaryIsHidden;
          });
        }
      });

    // get some positions after build() is done
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      // get height of TripSummaryCard
      if (_tscKey.currentContext != null) {
        if (_tscKey.currentContext!.size != null) {
          setState(() {
            _tscHeight = _tscKey.currentContext!.size!.height;
          });
        }
      }

      // get the position of the day labels
      final headerScrollDistance =
          (_appBarExpandedHeight - _appBarFoldedHeight) + // CrazyAppBar
              _tscHeight! + // TripSummaryCard
              30 * 2 * rh; // TripSummaryCard's padding

      _dayLabelPositions = [headerScrollDistance];

      // accumulated sum
      double scrollDistanceSum = headerScrollDistance;

      // get height of each day's activities
      for (int i = 0; i < trip.duration - 1; i++) {
        // find activities
        final nextDay = trip.startDate.add(Duration(days: i + 1));
        final previousDate = nextDay.subtract(const Duration(days: 2));
        final previousDay = DateTime(previousDate.year, previousDate.month,
            previousDate.day, 23, 59, 59);
        final activitiesOfTheDay = trip.activities
            .where((a) =>
                a.startTime.isBefore(nextDay) &&
                a.startTime.isAfter(previousDay))
            .toList();

        // add basic activities
        scrollDistanceSum += activitiesOfTheDay
                .where((a) =>
                    a.type != LocationType.accommodation &&
                    a.type != LocationType.transportation)
                .toList()
                .length *
            160 *
            rh;

        // add transportation
        scrollDistanceSum += activitiesOfTheDay
                .where((a) => a.type == LocationType.transportation)
                .toList()
                .length *
            45 *
            rh;

        // add title and separator (content: padding before & after text,
        // padding before the dash separator, text, and the dash separator)
        scrollDistanceSum += (20 * 2 + 20) * rh + 31 + 1;

        _dayLabelPositions.add(scrollDistanceSum);
      }
      print(_dayLabelPositions);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 标题栏
          CrazyAppBar(
            height: _appBarFoldedHeight,
            showCalendarIcon: _showCalendarIcon,
            kExpandedHeight: _appBarExpandedHeight,
            trip: trip,
            heroTag: _tscHeroTag,
            tscHeight: _tscHeight,
          ),
          // 行程概览
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0 * rh),
            child: UnconstrainedBox(child: tripSummaryCard),
          )),
          // 天数显示栏
          SliverPersistentHeader(
            delegate: PersistentHeaderDelegate(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(30),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  color: trip.getCoverLocation().palette!.color,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SizedBox(
                  height: _dayIndicatorHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    controller: _dayIndicatorController,
                    children: List.generate(
                      trip.duration,
                      (index) {
                        if (index == _currentDay) {
                          return GestureDetector(
                            key: _dayChipKeys[index],
                            onTap: () {
                              setState(() {
                                _currentDay = index;
                              });
                              _scrollToDay(_currentDay,
                                  dayIndicator: true, list: true);
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 10 * rw),
                              child: SizedBox(
                                width: 80 * rw,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        '第 ${index + 1} 天',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 19 * rw,
                                        ),
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: SizedBox(
                                        height: 4 * rh,
                                        width: 48 * rw,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            key: _dayChipKeys[index],
                            onTap: () {
                              setState(() {
                                _currentDay = index;
                              });
                              _scrollToDay(_currentDay,
                                  dayIndicator: true, list: true);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SizedBox(
                                width: 80 * rw,
                                child: Center(
                                  child: Text(
                                    '第 ${index + 1} 天',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18 * rw,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ) // add front and trailing padding
                      ..insert(0, SizedBox(width: 10 * rw))
                      ..add(SizedBox(
                          width: 18 *
                              rw)), // extra 8px to counter weird scroll effect
                  ),
                ),
              ),
              minHeight: _dayIndicatorHeight,
              maxHeight: _dayIndicatorHeight,
            ),
            pinned: true,
          ),
          // 活动卡
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  // top padding
                  return SizedBox(height: 20 * rh);
                } else if (index == trip.activities.length + 1) {
                  // trailing text
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20 * rh, bottom: 10 * rh),
                        child: const DashLineSeparator(
                          color: Colors.black54,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        child: const Text(
                          '行程结束',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  final act = trip.activities[index - 1];
                  final activityCard = GestureDetector(
                    onTap: () {
                      if (act.type == LocationType.transportation) {
                        // TODO: Open transportation info
                        null;
                      } else {
                        Navigator.of(context).push(
                          HeroDialogRoute(
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                value: act.location,
                                child: Center(
                                  child: LargeCard(
                                    h * 0.75,
                                    rw,
                                    w: w,
                                    heroTag:
                                        'activity-card-${trip.id}-${index - 1}',
                                    remarks:
                                        act.remarks == '' ? null : act.remarks,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                    // MUST wrap whatever widget inside an unconstrained box so that
                    // its parents can't dictate its constraints. This is needed
                    // because Slivers naturally ignores all children constraints
                    // to make the special effects.
                    child: UnconstrainedBox(
                      child: ActivityCard(
                        heroTag: 'activity-card-${trip.id}-${index - 1}',
                        activity: trip.activities[index - 1],
                      ),
                    ),
                  );
                  // check if it's the first activity of the day
                  final previousDay = index >= 2
                      ? trip.activities[index - 2].startTime.day
                      : act.startTime.day - 1;
                  if (act.startTime.day == previousDay + 1) {
                    final dayInTrip =
                        act.startTime.day - trip.activities[0].startTime.day;
                    return Column(
                      children: [
                        if (dayInTrip != 0)
                          Padding(
                            padding: EdgeInsets.all(20.0 * rh),
                            child: const DashLineSeparator(
                              color: Colors.black54,
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20 * rh),
                          child: Text(
                            '第 ${dayInTrip + 1} 天',
                            key: _dayLabelKeys[dayInTrip],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 22 * rh,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        activityCard,
                      ],
                    );
                  } else {
                    return activityCard;
                  }
                }
              },
              childCount: trip.activities.length + 2, // plus two paddings
            ),
          ),
        ],
      ),
    );
  }
}

class CrazyAppBar extends StatelessWidget {
  const CrazyAppBar({
    Key? key,
    required bool showCalendarIcon,
    required this.kExpandedHeight,
    required this.trip,
    required String heroTag,
    required this.height,
    this.tscHeight,
  })  : _showCalendarIcon = showCalendarIcon,
        _heroTag = heroTag,
        super(key: key);

  final bool _showCalendarIcon;
  final double kExpandedHeight;
  final Trip trip;
  final String _heroTag;
  final double height;
  final double? tscHeight;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: trip.getCoverLocation().palette!.color,
      actions: [
        if (_showCalendarIcon)
          Hero(
            tag: _heroTag,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    HeroDialogRoute(builder: (context) {
                      return Center(
                        child: Material(
                          color: Colors.transparent,
                          child: TripSummaryCard(
                            trip: trip,
                            heroTag: _heroTag,
                            tscHeight: tscHeight,
                          ),
                        ),
                      );
                    }),
                  );
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: trigger share pannel
          },
        ),
      ],
      expandedHeight: kExpandedHeight,
      toolbarHeight: height,
      pinned: true,
      stretch: true,
      onStretchTrigger: () async {
        // TODO: Refresh Data
      },
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(trip.name),
            Text(
              '${trip.activities.where((a) => a.type != LocationType.transportation).length} 个游玩点 | ${trip.startDate.toChineseString()} 出发',
              style: Theme.of(context).textTheme.headline3,
            ),
          ],
        ),
        background: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Hero(
            tag: trip.id + 'image',
            child: Image(
              image: trip.getCoverImage().image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

/// This is a mixin class that makes a sliver behave like the persistent header
/// on a web page. It is used by CrazyAppBar and DayIndicator, which are
/// exclusive to this file. If other screens need it too, consider making this
/// a helper widget and place it in /lib/headers instead.
class PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  PersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(PersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
