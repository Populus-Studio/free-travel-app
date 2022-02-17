import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip.dart';
import '../providers/trips.dart';
import '../providers/location.dart';
import '../utils.dart';

class TripCard extends StatefulWidget {
  final id;
  const TripCard({required this.id, Key? key}) : super(key: key);

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  late final h = MediaQuery.of(context).size.height;
  late final w = MediaQuery.of(context).size.width;
  late final rh = h / Utils.h13pm;
  late final rw = w / Utils.w13pm;
  late final Future<Trip> _future;
  late final Location _coverLocation;

  Future<Trip> loadData() async {
    final trip = await Provider.of<Trips>(context, listen: false)
        .fetchTripById(widget.id);
    await trip.activities
        .firstWhere((a) => a.locationId == trip.coverLocationId)
        .location
        .loadImage();
    _coverLocation = trip.activities
        .firstWhere((a) => a.locationId == trip.coverLocationId)
        .location;
    return trip;
  }

  @override
  void initState() {
    _future = loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Trip>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final trip = snapshot.data!; // this is definitely not null
            print(trip.coverLocationId);
            return Container(
              height: 120 * rh,
              width: 380 * rw,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _coverLocation.palette!.color,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10 * rw, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: Theme.of(context).textTheme.headline2,
                          ),
                          SizedBox(height: 5 * rh),
                          Text(
                              '${trip.activities.length} 个游玩点 | ${trip.startDate.toLocal()}')
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
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
        });
  }
}
