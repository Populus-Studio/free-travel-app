import 'package:flutter/material.dart';

import '../providers/location.dart';
import '../providers/activity.dart';
import '../utils.dart';

class ActivityCard extends StatelessWidget {
  ActivityCard({
    required this.activity,
    Key? key,
  }) : super(key: key) {
    height = activity.duration * 1.5;
  }

  final Activity activity;
  late final double height;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;
    if (activity.type == LocationType.transportation) {
      return SizedBox(
        height: height * rh,
        width: 380 * rh,
        child: Placeholder(),
      ); // TODO: Draw a dashed line here
    } else {
      return ImageCard(rw: rw, height: height, rh: rh, activity: activity);
    }
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
    return GestureDetector(
      onTap: () {
        // TODO: Finish this
      },
      child: Container(
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
      ),
    );
  }
}
