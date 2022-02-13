import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip.dart';
import '../utils.dart';

class TripCard extends StatelessWidget {
  TripCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // These variables can only be calculated here because it's
    // a stateless widget.
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final rh = h / Utils.h13pm;
    final rw = w / Utils.w13pm;

    final trip = Provider.of<Trip>(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
