import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip.dart';
import '../providers/trips.dart';

/// This screen gets tripId from route arguments.
class TripScreen extends StatefulWidget {
  static const routeName = '/trip-screen';
  const TripScreen({Key? key}) : super(key: key);

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late final Future<Trip> _future;
  @override
  void didChangeDependencies() {
    final tripId = ModalRoute.of(context)?.settings.arguments as String;
    _future = Provider.of<Trips>(context).fetchTripById(tripId);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar();
  }
}
