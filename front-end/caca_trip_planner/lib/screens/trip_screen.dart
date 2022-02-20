import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  late final dayIndicatorHeight = 40 * rh;
  late final ScrollController _scrollController;
  late final kExpandedHeight = 240 * rh;
  bool _showTitle = false;
  int _currentDay = 1;
  final double paddingSize = 10;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        // TDOO: update current day
        // determine if title should show based on current scroll position
        final isNotExpanded = _scrollController.hasClients &&
            _scrollController.offset > kExpandedHeight - kToolbarHeight;
        if (isNotExpanded != _showTitle) {
          setState(() {
            // update only the fields that need updating
            _showTitle = isNotExpanded;
          });
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tripSummaryCard = TripSummaryCard(trip: trip);
    final dayIndicator = SizedBox(
      height: dayIndicatorHeight,
      child: Text(
        '第 $_currentDay 天 / 共 ${trip.duration} 天',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CrazyAppBar(kExpandedHeight: kExpandedHeight, trip: trip, rh: rh),
          SliverPersistentHeader(
            delegate: PersistentHeaderDelegate(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingSize),
                      child: tripSummaryCard,
                    ),
                    dayIndicator,
                  ],
                ),
              ),
              minHeight: tripSummaryCard.height13pm * rh +
                  dayIndicatorHeight +
                  2 * paddingSize,
              maxHeight: tripSummaryCard.height13pm * rh +
                  dayIndicatorHeight +
                  2 * paddingSize,
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 1000,
                  child: Placeholder(),
                ),
              ],
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
    required this.kExpandedHeight,
    required this.trip,
    required this.rh,
  }) : super(key: key);

  final double kExpandedHeight;
  final Trip trip;
  final double rh;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: trigger share pannel
          },
        )
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
            Hero(
              tag: trip.id + 'title',
              child: Text(trip.name),
            ),
            Hero(
              tag: trip.id + 'info',
              child: Text(
                '${trip.activities.where((a) => a.type != LocationType.transportation).length} 个游玩点 | ${trip.startDate.toChineseString()} 出发',
                style: Theme.of(context).textTheme.headline3,
              ),
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
