import 'package:cacatripplanner/helpers/dot_widget.dart';
import 'package:cacatripplanner/providers/location.dart';
import 'package:flutter/material.dart';

import '../providers/activity.dart';
import '../providers/trip.dart';
import '../utils.dart';

class TripSummaryCard extends StatefulWidget {
  final Trip trip;
  final String? _heroTag;
  final double? tscHeight;
  late double _height13pm;
  late double _width13pm;

  TripSummaryCard({
    required this.trip,
    String? heroTag,
    this.tscHeight,
    Key? key,
  })  : _heroTag = heroTag,
        super(key: key) {
    // TODO: Calculate height and width according to activities here.
    _height13pm = 120;
    _width13pm = 380;
  }

  @override
  State<TripSummaryCard> createState() => _TripSummaryCardState();
}

class _TripSummaryCardState extends State<TripSummaryCard> {
  double get height13pm => widget._height13pm;
  double get width13pm => widget._width13pm;

  /// This helper future helps Flutter render an animation with no real content.
  late final Future _helperFuture;

  @override
  void initState() {
    // By the way, this is very stupid because it would literally result in
    // building the same widget twice, but sadly Flutter does not have an
    // elegant solution to this...
    _helperFuture = Future<void>.delayed(const Duration(milliseconds: 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;
    final _content = TripSummaryCardContent(
      width13pm: widget._width13pm,
      rw: rw,
      trip: widget.trip,
      empty: false,
      tscHeight: widget.tscHeight, // this is a bit redundant though...
    );
    final _emptyContent = TripSummaryCardContent(
      width13pm: widget._width13pm,
      rw: rw,
      trip: widget.trip,
      empty: true,
      tscHeight: widget.tscHeight,
    );

    if (widget._heroTag != null) {
      return FutureBuilder<void>(
        future: _helperFuture,
        builder: (context, snapshot) {
          late final Widget _child;
          if (snapshot.connectionState == ConnectionState.done) {
            _child = _content;
          } else {
            _child = _emptyContent;
            // _child = _content;
          }
          // Very unfortunately, AnimatedSwitcher couldn't generate an animation
          // for this widget switch. But let's leave it here and pray for future
          // improvements, shall we?
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            // Use SafeArea in case duration is too long!
            child: SafeArea(
                child: Hero(
              tag: widget._heroTag!,
              child: _child,
            )),
          );
        },
      );
    } else {
      return _content;
    }
  }
}

class TripSummaryCardContent extends StatelessWidget {
  const TripSummaryCardContent({
    Key? key,
    required double width13pm,
    required this.rw,
    required this.trip,
    // whether to render a card with no content for animation purposes
    required this.empty,
    // whether the card's size is already known
    this.tscHeight,
  })  : _width13pm = width13pm,
        super(key: key);

  final double _width13pm;
  final double rw;
  final Trip trip;
  final bool empty;
  final double? tscHeight;

  @override
  Widget build(BuildContext context) {
    // TODO: get height
    return Container(
      height: tscHeight,
      width: _width13pm * rw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: trip.getCoverLocation().palette!.color,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: !empty
          ? SingleChildScrollView(
              // In case itinerary is too long!
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('行程概览', style: TextStyle(fontSize: 25)),
                      GestureDetector(
                        onTap: () {
                          // TODO: Open map
                        },
                        child: Row(
                          children: const [
                            Icon(
                              Icons.map_outlined,
                              color: Colors.white70,
                            ),
                            Text('  路线地图 >'),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...List.generate(trip.duration, (index) {
                    final nextDate =
                        trip.startDate.add(Duration(days: index + 1));
                    final nextDay = DateTime(
                        nextDate.year, nextDate.month, nextDate.day, 0, 0, 0);
                    final previousDate =
                        nextDay.subtract(const Duration(days: 2));
                    final previousDay = DateTime(previousDate.year,
                        previousDate.month, previousDate.day, 23, 59, 59);
                    final activitiesOfTheDay = trip.activities
                        .where(
                          (a) =>
                              a.type != LocationType.transportation &&
                              a.type != LocationType.accommodation &&
                              a.startTime.isBefore(nextDay) &&
                              a.startTime.isAfter(previousDay),
                        )
                        .toList();
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'D${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            // USE Expanded TO LIMIT Wrap WIDGET!!!
                            child: Wrap(
                              direction: Axis.horizontal,
                              runSpacing: 5,
                              children: List.generate(activitiesOfTheDay.length,
                                  (index) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          activitiesOfTheDay[index]
                                              // .location
                                              .name,
                                        ),
                                      ),
                                    ),
                                    if (index != activitiesOfTheDay.length - 1)
                                      const DotWidget(
                                        dashColor: Colors.grey,
                                        dashHeight: 2,
                                        emptyWidth: 0,
                                        totalWidth: 20,
                                      )
                                  ],
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
          : Container(),
    );
  }
}
