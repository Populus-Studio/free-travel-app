import 'package:cacatripplanner/screens/trip_screen.dart';
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
        .fetchTripById(widget.id, test: false)
        .catchError((err) {
      String msg = '';
      if ((err as String).contains('Signature')) msg = '请重新登录';
      Utils.showMaterialAlertDialog(
          context, '获取行程失败', Text('行程 ID：${widget.id}\n错误信息：$err\n$msg'));
      throw err;
    });
    await trip.getCoverLocation().loadImage();
    _coverLocation = trip.getCoverLocation();
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
            return GestureDetector(
              onTap: () async {
                for (var act in trip.activities) {
                  await act.location?.loadImage();
                }
                Navigator.of(context)
                    .pushNamed(TripScreen.routeName, arguments: trip);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 8.0,
                child: Container(
                  height: 120 * rh,
                  width: 380 * rw,
                  // width: 380 * rw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _coverLocation.palette!.color,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 190 * rw,
                          padding: EdgeInsets.symmetric(horizontal: 15 * rw),
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
                                '${trip.activities.where((a) => a.type != LocationType.transportation).length} 个游玩点 | ${trip.startDate.toChineseString()}',
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 120 * rh,
                          width: 190 * rw,
                          child: Hero(
                            tag: trip.id + 'image',
                            child: Image(
                              image: trip.getCoverImage().image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (!snapshot.hasError) {
            return Container(
              height: 120 * rh,
              width: 380 * rw,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black38,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 190 * rw,
                      padding: EdgeInsets.symmetric(horizontal: 15 * rw),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: DecoratedBox(
                              decoration:
                                  const BoxDecoration(color: Colors.white10),
                              child: SizedBox(
                                height: 18 * rh,
                                width: 150 * rw,
                              ),
                            ),
                          ),
                          SizedBox(height: 15 * rh),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: DecoratedBox(
                              decoration:
                                  const BoxDecoration(color: Colors.white10),
                              child: SizedBox(
                                height: 15 * rh,
                                width: 200 * rw,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(color: Colors.white10),
                      child: SizedBox(
                        height: 120 * rh,
                        width: 190 * rw,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
