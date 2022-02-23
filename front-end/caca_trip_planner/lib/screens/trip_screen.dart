import 'package:cacatripplanner/helpers/hero_dialog_route.dart';
import 'package:cacatripplanner/widgets/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_palette/flutter_palette.dart';
import 'dart:math' as math;

import '../widgets/trip_summary_card.dart';
import '../widgets/trip_card.dart';
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
  late final dayIndicatorHeight = 50 * rh;
  late final ScrollController _scrollController;
  late final ScrollController _dayIndicatorController;
  late final kExpandedHeight = 240 * rh;
  late final _heroTag = 'trip-summary-card-' + trip.id;
  bool _showAppBar = false;
  bool _showCalendarIcon = false;
  int _currentDay = 0;
  final double paddingSize = 10;

  /// This TripSummaryCard has no hero tag!
  late final tripSummaryCard = TripSummaryCard(trip: trip);

  @override
  void initState() {
    _dayIndicatorController = ScrollController()
      ..addListener(() {}); // TODO: implmt controller here
    _scrollController = ScrollController()
      ..addListener(() {
        // TDOO: update current day
        // determine if title should show based on current scroll position
        final isNotExpanded = _scrollController.hasClients &&
            _scrollController.offset > kExpandedHeight - kToolbarHeight;
        final summaryIsHidden = true; // TODO: Check if summary is hidden
        if (isNotExpanded != _showAppBar) {
          setState(() {
            // update only the fields that need updating
            _showAppBar = isNotExpanded;
          });
        }
        if (summaryIsHidden != _showCalendarIcon) {
          setState(() {
            _showCalendarIcon = summaryIsHidden;
          });
        }
        // TODO: Update _currentDay
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
            showCalendarIcon: _showCalendarIcon,
            kExpandedHeight: kExpandedHeight,
            trip: trip,
            tripSummaryCard: tripSummaryCard,
            heroTag: _heroTag,
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
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: trip.getCoverLocation().palette!.color,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: dayIndicatorHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      controller: _dayIndicatorController,
                      children: List.generate(
                        trip.duration,
                        (index) {
                          if (index == _currentDay) {
                            // final boxWidth = 60 * rw;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentDay = index;
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        '第 ${index + 1} 天',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                          fontSize: 19 * rw,
                                        ),
                                      ),
                                    ),
                                    DecoratedBox(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        // trip
                                        //     .getCoverLocation()
                                        //     .palette!
                                        //     .color
                                      ),
                                      child: SizedBox(
                                        height: 4 * rh,
                                        width: 48 * rw,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentDay = index;
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    '第 ${index + 1} 天',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 18 * rw,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                        ..insert(0, const SizedBox(width: 10))
                        ..add(const SizedBox(width: 10)),
                    ),
                  ),
                ),
              ),
              minHeight: dayIndicatorHeight,
              maxHeight: dayIndicatorHeight,
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // MUST wrap whatever widget inside an unconstrained box so that
                // its parents can't dictate its constraints. This is needed
                // because Slivers naturally ignores all children constraints
                // to make the special effects.
                return UnconstrainedBox(
                  child: ActivityCard(activity: trip.activities[index]),
                );
              },
              childCount: trip.activities.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// This is deprecatred because it's not scrollable and it does not interact.
class DayIndicator extends StatelessWidget {
  const DayIndicator({
    Key? key,
    required this.dayIndicatorHeight,
    required int currentDay,
    required this.trip,
    required this.palette,
    required this.rh,
    required this.rw,
  })  : _currentDay = currentDay,
        super(key: key);

  final double dayIndicatorHeight;
  final int _currentDay;
  final Trip trip;
  final PaletteColor palette;
  final double rh;
  final double rw;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(25.0),
        topLeft: Radius.circular(25.0),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 2,
                blurStyle: BlurStyle.outer,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.color.withOpacity(0.5),
                ColorPalette.splitComplimentary(palette.color)
                    .last
                    .withOpacity(0.5),
              ],
            ),
          ),
          child: SizedBox(
            height: dayIndicatorHeight,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  trip.duration,
                  (index) {
                    if (index == _currentDay) {
                      final boxWidth = 60 * rw;
                      return GestureDetector(
                        onTap: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: boxWidth,
                              child: FittedBox(
                                child: Text(
                                  '第 $index 天',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(color: palette.color),
                              child: SizedBox(
                                height: 5 * rh,
                                width: boxWidth * 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Text(
                        '第 $index 天',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18 * rw,
                          // fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
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
    required this.tripSummaryCard,
    required String heroTag,
  })  : _showCalendarIcon = showCalendarIcon,
        _heroTag = heroTag,
        super(key: key);

  final bool _showCalendarIcon;
  final double kExpandedHeight;
  final Trip trip;
  final TripSummaryCard tripSummaryCard;
  final String _heroTag;

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
                  // TODO: Show itinery here
                  Navigator.of(context).push(
                    HeroDialogRoute(builder: (context) {
                      return Center(
                        child: Material(
                          color: Colors.transparent,
                          elevation: 2,
                          child: TripSummaryCard(
                            trip: trip,
                            heroTag: _heroTag,
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
      toolbarHeight: 75,
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
