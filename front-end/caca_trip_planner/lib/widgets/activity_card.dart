import 'package:cacatripplanner/helpers/hero_dialog_route.dart';
import 'package:cacatripplanner/helpers/sticky_note.dart';
import 'package:cacatripplanner/widgets/large_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';
import '../providers/activity.dart';
import '../utils.dart';

class ActivityCard extends StatelessWidget {
  ActivityCard({
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
    height = 160 * rh;
    if (activity.type == LocationType.transportation) {
      if (_heroTag != null) {
        return Hero(
          tag: _heroTag!,
          child: Material(
            color: Colors.transparent,
            child: TransportationCardContent(
              rh: rh,
              rw: rw,
              activity: activity,
            ),
          ),
        ); // TODO: Draw a dashed line here
      } else {
        return TransportationCardContent(
          rh: rh,
          rw: rw,
          activity: activity,
        );
      }
    } else {
      if (_heroTag != null) {
        return Hero(
          tag: _heroTag!,
          child: Material(
            color: Colors.transparent,
            child: LocationCardContent(
              rw: rw,
              height: height,
              rh: rh,
              activity: activity,
            ),
          ),
        );
      } else {
        return LocationCardContent(
          rw: rw,
          height: height,
          rh: rh,
          activity: activity,
        );
      }
    }
  }
}

class TransportationCardContent extends StatelessWidget {
  const TransportationCardContent({
    Key? key,
    required this.rh,
    required this.rw,
    required this.activity,
  }) : super(key: key);

  final double rh;
  final double rw;
  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45 * rh,
      width: 380 * rw,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 30 * rw),
              DecoratedBox(
                decoration: const BoxDecoration(color: Colors.grey),
                child: SizedBox(
                  height: 50 * rh,
                  width: 5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                activity.name.toTransportationIcon(),
                color: Colors.black54,
              ),
              Text(' 约 ${activity.duration.toChineseDurationString()} > ',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationCardContent extends StatelessWidget {
  const LocationCardContent({
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
        color: activity.location.palette!.color,
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                // padding: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 0,
                  bottom: 0,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    // topRight: Radius.circular(10),
                    // bottomRight: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: SizedBox(
                    child: Image(
                      image: activity.location.img.image,
                      fit: BoxFit.cover,
                    ),
                    height: height * rh,
                    width: 380 * rw * 0.31,
                  ),
                ),
              ),
              SizedBox(width: 4 * rw),
              // A row does not impose constraints to its children, unless they are
              // wrapped in an Expanded widget.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10 * rw),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名字
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            activity.name,
                            style: TextStyle(
                              fontSize: 20 * rw,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4 * rw),
                          Container(
                            height: 17,
                            width:
                                13.0 * activity.type.toChineseString().length,
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            child: FittedBox(
                                child: Text(activity.type.toChineseString())),
                          )
                        ],
                      ),
                      // 介绍
                      if (activity.location.description != '')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.location.description,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.white60,
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight),
                              ),
                              child: SizedBox(
                                height: 4 * rh,
                                width: 100 * rw,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10 * rh),
                      // 评分
                      // Row(
                      //   children: [
                      //     for (int i = 1; i <= 5; i++)
                      //       Icon(
                      //         activity.location.rate < i
                      //             ? Icons.star_border
                      //             : Icons.star,
                      //         color: Colors.white,
                      //         size: 16,
                      //       ),
                      //   ],
                      // ),
                      // SizedBox(width: 5 * rw),
                      // Text(
                      //   '${activity.location.rate} 分',
                      //   style: TextStyle(
                      //     color: Colors.white.withOpacity(0.95),
                      //     // fontSize: 16 * rw,
                      //   ),
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: const BorderRadius.all(Radius.circular(5)),
                      //     border: Border.all(color: Colors.grey),
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(5.0),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           '游玩约 ' +
                      //               activity.duration.toChineseDurationString(),
                      //         ),
                      //         if (activity.remarks != '')
                      //           Text(
                      //             '备注：' + activity.remarks,
                      //             maxLines: 3,
                      //             softWrap: true,
                      //             overflow: TextOverflow.ellipsis,
                      //           )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                          Text(
                            ' 游玩约 ' +
                                activity.duration.toChineseDurationString(),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * rh),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          Text(
                            " 预计花费￥${activity.cost.toStringAsFixed(0)} 元",
                          ),
                        ],
                      ),
                      // SizedBox(height: 4 * rh),
                      // if (activity.remarks != '')
                      //   Center(
                      //     child: SizedBox(
                      //       height: 60 * rh,
                      //       width: 200 * rw,
                      //       child: StickyNote(
                      //         child: Padding(
                      //           padding:
                      //               const EdgeInsets.only(left: 13.0, right: 4.0),
                      //           child: Text(
                      //             activity.remarks,
                      //             style: const TextStyle(
                      //               // color: Colors.black,
                      //               fontFamily: 'AaManYuShouXieTi',
                      //               fontSize: 15,
                      //             ),
                      //             maxLines: 2,
                      //             softWrap: true,
                      //             overflow: TextOverflow.ellipsis,
                      //           ),
                      //         ),
                      //         color: activity.location.palette!.color.lighten(),
                      //         // color: Colors.yellow,
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (activity.remarks != '')
            const Positioned(
              bottom: 10,
              right: 10,
              child: Icon(
                Icons.sticky_note_2,
                color: Colors.white70,
              ),
            ),
          if (activity.location.isFavorite)
            const Positioned(
              right: 10,
              top: 10,
              child: Icon(
                Icons.favorite,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}
