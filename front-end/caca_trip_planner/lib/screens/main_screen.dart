import 'package:cacatripplanner/helpers/dummy_data.dart';
import 'package:cacatripplanner/helpers/sticky_note.dart';
import 'package:cacatripplanner/providers/trip.dart';
import 'package:cacatripplanner/providers/trips.dart';
import 'package:cacatripplanner/screens/login_screen.dart';
import 'package:cacatripplanner/screens/singup_screen.dart';
import 'package:cacatripplanner/utils.dart';
import 'package:cacatripplanner/widgets/recommendation_card.dart';
import 'package:cacatripplanner/widgets/trip_card.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '/screens/select_screen.dart';
import '/providers/locations.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main-screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final h = MediaQuery.of(context).size.height;
  late final w = MediaQuery.of(context).size.width;
  late final rh = h / Utils.h13pm;
  late final rw = w / Utils.w13pm;
  late final int _numOfTripCard;

  late final Future<List<Trip>> _recentTrips;
  late final Future<List<Trip>> _recommendedTrips;

  @override
  void initState() {
    // submit two tasks
    _recentTrips = Provider.of<Trips>(context, listen: false)
        .fetchTripByType(recent: true, num: 4);
    _recommendedTrips = Provider.of<Trips>(context, listen: false)
        .fetchTripByType(recommended: true, num: 4);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // count how many small trip cards can fit here:
    // h - tab bar - top padding - two texts - one recomm card
    _numOfTripCard = (h - 90 * rh * rh - 90 * rh - 30 * 2 * rh - 330 * rh) ~/
        ((160 + 10) * rh);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 90 * rh * rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23 * rw),
            child: Text(
              '近期行程',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 30 * rh,
              ),
            ),
          ),
          Center(
            child: FutureBuilder<List<Trip>>(
              future: _recentTrips,
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  final trips = snapshot.data;
                  return Column(
                    children: List.generate(
                        _numOfTripCard < trips!.length
                            ? _numOfTripCard
                            : trips.length,
                        (index) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0 * rh),
                              child: TripCard(
                                  id: trips[index].id, key: GlobalKey()),
                            )),
                  );
                } else if (!snapshot.hasError) {
                  return Column(
                    children: List.generate(
                        _numOfTripCard,
                        (index) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0 * rh),
                              child: const TripCard(id: ''),
                            )),
                  );
                } else {
                  return const Center();
                }
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23 * rw),
            child: Text(
              '探索下一程',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 30 * rh,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5 * rh),
            height: 345 * rh,
            child: FutureBuilder<List<Trip>>(
              future: _recommendedTrips,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final trips = snapshot.data!;
                  return Swiper(
                    itemCount: trips.length,
                    viewportFraction: 0.8,
                    scale: 0.9,
                    itemBuilder: (context, index) {
                      return RecommendationCard(
                          trip: trips[index], key: GlobalKey());
                    },
                  );
                } else {
                  return Swiper(
                    itemCount: 3,
                    viewportFraction: 0.8,
                    scale: 0.9,
                    itemBuilder: (context, index) {
                      return const RecommendationCard(trip: null);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
