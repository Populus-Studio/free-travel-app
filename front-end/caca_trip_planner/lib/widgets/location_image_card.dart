import 'package:cacatripplanner/helpers/hero_dialog_route.dart';
import 'package:cacatripplanner/widgets/large_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';
import '../providers/activity.dart';
import '../utils.dart';

class LocationImageCard extends StatelessWidget {
  LocationImageCard({
    required this.activity,
    String? heroTag,
    Key? key,
  })  : _heroTag = heroTag,
        // height = activity.duration * 1.5,
        super(key: key);

  final Activity activity;
  late final double height;
  final String? _heroTag;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;
    height = 180 * rh;
    if (activity.type == LocationType.transportation) {
      if (_heroTag != null) {
        return Hero(
          tag: _heroTag!,
          child: Material(
            color: Colors.transparent,
            child: TransportationCard(rh: rh),
          ),
        ); // TODO: Draw a dashed line here
      } else {
        return TransportationCard(rh: rh);
      }
    } else {
      if (_heroTag != null) {
        return Hero(
          tag: _heroTag!,
          child: Material(
            color: Colors.transparent,
            child: ImageCard(
              rw: rw,
              height: height,
              rh: rh,
              activity: activity,
            ),
          ),
        );
      } else {
        return ImageCard(
          rw: rw,
          height: height,
          rh: rh,
          activity: activity,
        );
      }
    }
  }
}

class TransportationCard extends StatelessWidget {
  const TransportationCard({
    Key? key,
    required this.rh,
  }) : super(key: key);

  final double rh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50 * rh,
      width: 380 * rh,
      child: Placeholder(),
    );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({
    Key? key,
    required this.rw,
    required this.height,
    required this.rh,
    required this.activity,
  }) : super(key: key);

  final double rw;
  final double height;
  final double rh;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380 * rw,
      height: height * rh,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          // This is to make the stack as big as the container! Very crucial!
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.lerp(
                      Alignment.bottomCenter, Alignment.topCenter, 0.3)!,
                ),
              ),
              position: DecorationPosition.foreground,
              child: Image(
                image: activity.location.img.image,
                fit: BoxFit.cover,
              ),
            ),
            PositionedDirectional(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              bottom: 0,
            ),
          ],
        ),
      ),
    );
  }
}
