import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils.dart';
import '../providers/trip.dart';
import '../providers/location.dart';
import '../providers/trips.dart';
import '../screens/trip_screen.dart';

/// Unlike TripCard, RecommendationCard takes a fully loaded trip.
class RecommendationCard extends StatefulWidget {
  final Trip? trip;
  const RecommendationCard({required this.trip, Key? key}) : super(key: key);

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  late final h = MediaQuery.of(context).size.height;
  late final w = MediaQuery.of(context).size.width;
  late final rh = h /
      Utils
          .h13pm; // This widget is subject to rh because otherwise it would look dumb on small devices.
  late final rw = w / Utils.w13pm;
  late final Location _coverLocation;
  late final String _imageHeroTag =
      widget.trip == null ? '' : widget.trip!.id + 'image-recommended';

  @override
  void initState() {
    if (widget.trip != null) {
      _coverLocation = widget.trip!.getCoverLocation();
      widget.trip!.getCoverLocation().loadImage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trip == null) return WaitingCard(rh: rh, rw: rw);
    final Trip trip = widget.trip!;
    return GestureDetector(
      onTap: () async {
        for (var act in trip.activities) {
          await act.location?.loadImage();
        }
        Navigator.of(context).pushNamed(TripScreen.routeName, arguments: {
          'trip': trip,
          'imageHeroTag': _imageHeroTag,
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Container(
          height: 330 * rh,
          width: 380 * rw,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _coverLocation.palette!.color,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                SizedBox(
                  height: 330 * rh * 0.70,
                  width: 380 * rw,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _coverLocation.palette!.color,
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.lerp(Alignment.bottomCenter,
                                Alignment.topCenter, 0.2)!,
                          ),
                        ),
                        position: DecorationPosition.foreground,
                        child: Hero(
                          tag: _imageHeroTag,
                          child: Image(
                            image: trip.getCoverImage().image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15,
                        bottom: 3,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pin_drop,
                              color: Colors.white,
                            ),
                            Text(' ' + _coverLocation.name),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 330 *
                        rh *
                        0.22 *
                        0.22, // take 22% of the bottom space for padding
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${trip.activities.where((a) => a.type != LocationType.transportation).length} 个游玩点 | ${trip.duration} 天',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                              Text(
                                ' ' + trip.username,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money_rounded,
                                color: Colors.white70,
                              ),
                              Text(
                                ' ${trip.totalCost} 元',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WaitingCard extends StatelessWidget {
  const WaitingCard({
    Key? key,
    required this.rh,
    required this.rw,
  }) : super(key: key);

  final double rh;
  final double rw;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 330 * rh,
        width: 380 * rw,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black38,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Stack(
                // fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white10,
                    ),
                    child: SizedBox(
                      height: 330 * rh * 0.7,
                      width: 380 * rw,
                    ),
                  ),
                  Positioned(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Colors.white10),
                        child: SizedBox(
                          height: 20,
                          width: 70 * rw,
                        ),
                      ),
                    ),
                    bottom: 6,
                    left: 15,
                  )
                ],
              ),
              Container(
                width: 380 * rw,
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 330 *
                      rh *
                      0.22 *
                      0.3, // take 30% of the bottom space for padding
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左边的两排文字
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.white10),
                            child: SizedBox(
                              height: 18,
                              width: 150 * rw,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.white10),
                            child: SizedBox(
                              height: 15,
                              width: 170 * rw,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 右边的两排文字
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.white10),
                            child: SizedBox(
                              height: 15,
                              width: 100 * rw,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.white10),
                            child: SizedBox(
                              height: 15,
                              width: 100 * rw,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
