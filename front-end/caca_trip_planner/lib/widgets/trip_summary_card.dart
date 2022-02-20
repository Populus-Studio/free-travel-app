import 'package:flutter/material.dart';

import '../providers/trip.dart';
import '../utils.dart';

class TripSummaryCard extends StatelessWidget {
  final Trip trip;
  //
  late double _height13pm;
  late double _width13pm;

  TripSummaryCard({required this.trip, Key? key}) : super(key: key) {
    // TODO: Calculate height and width according to activities here.
    _height13pm = 120;
    _width13pm = 380;
  }

  double get height13pm => _height13pm;
  double get width13pm => _width13pm;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;

    return Container(
      height: _height13pm * rh,
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
    );
  }
}
