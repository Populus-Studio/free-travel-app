import 'package:cacatripplanner/helpers/dash_line_separator.dart';
import 'package:cacatripplanner/helpers/flippable_page_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip_builder/page_flip_builder.dart';
import 'package:provider/provider.dart';

import '../helpers/hero_dialog_route.dart';
import '../helpers/sticky_note.dart';
import '../providers/activity.dart';
import '../providers/location.dart';
import '../utils.dart';

/// The LargeCard does not have a constraint when it's called without a heroTag,
/// as this indicates that it's being called from a select screen, which changes
/// the cards' sizes to play animation. If called with a heroTag, it is persumed
/// that it's called by tapping on an ActivityCard, in which case it should have
/// a size so it does not fill the whole screen.
class LargeCard extends StatefulWidget {
  // final Location loc;
  final double maxHeight;
  final double w;
  late final double imageHeight;
  late final double separatorHeight;
  final double rw;
  final String? _heroTag;
  final Location? location;
  final Activity? activity;

  LargeCard(
    this.maxHeight,
    this.rw, {
    Key? key,
    required this.w,
    String? heroTag,
    this.location,
    this.activity,
  })  : _heroTag = heroTag,
        super(key: key) {
    imageHeight = maxHeight * 0.4;
    separatorHeight = maxHeight * 0.005;
  }

  @override
  State<LargeCard> createState() => _LargeCardState();
}

class _LargeCardState extends State<LargeCard> {
  /// To control page flip
  final pageFlipKey = GlobalKey<PageFlipBuilderState>();

  /// Flip callback that is passed to multiple places
  void _onFlip() => pageFlipKey.currentState?.flip();

  @override
  Widget build(BuildContext context) {
    late final Location loc;
    if (widget.location != null) {
      loc = widget.location!;
    } else {
      // Here is the receiver of the Location Provider.
      loc = Provider.of<Location>(context, listen: true);
    }

    // build front side content accroding to type
    late final Widget frontSideContent;
    if (widget.activity != null) {
      // build large activity card
      frontSideContent = ActivityInfoContent(
        widget.activity!,
        imageHeight: widget.imageHeight,
        rw: widget.rw,
        separatorHeight: widget.separatorHeight,
      );
    } else {
      // build recommendation card
      frontSideContent = LocationInfoContent(
        loc,
        imageHeight: widget.imageHeight,
        separatorHeight: widget.separatorHeight,
        rw: widget.rw,
      );
    }

    if (widget._heroTag != null) {
      final backSideContent = BackSideContent(
        loc: loc,
        separatorHeight: widget.separatorHeight,
        rw: widget.rw,
      );

      // build a flippable card
      final flippableCard = PageFlipBuilder(
        frontBuilder: (_) => frontSideContent,
        backBuilder: (_) => backSideContent,
        flipAxis: Axis.horizontal,
        maxScale: 0.2,
        maxTilt: 0.003,
        onFlipComplete: (isFrontSide) => HapticFeedback.lightImpact(),
      );

      // return a flippable card
      return Hero(
        tag: widget._heroTag!,
        child: Material(
          child: SizedBox(
            height: widget.maxHeight + 10,
            width: widget.w * 0.93,
            child: flippableCard,
          ),
          color: Colors.transparent,
        ),
      );
    } else {
      // return a normal large card
      return Hero(
        tag: 'large-card-${loc.id}',
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              HeroDialogRoute(
                builder: (context) {
                  return ChangeNotifierProvider.value(
                    value: loc,
                    child: Center(
                      child: LargeCard(
                        widget.maxHeight,
                        widget.rw,
                        w: widget.w,
                        heroTag: 'large-card-${loc.id}',
                      ),
                    ),
                  );
                },
              ),
            );
            // send vibration feedback
            HapticFeedback.selectionClick();
          },
          child: Material(
            child: frontSideContent,
            color: Colors.transparent,
          ),
        ),
      );
    }
  }
}

class LocationInfoContent extends StatefulWidget {
  const LocationInfoContent(
    this.loc, {
    required this.imageHeight,
    required this.separatorHeight,
    required this.rw,
    Key? key,
  }) : super(key: key);

  final Location loc;
  final double imageHeight;
  final double separatorHeight;
  final double rw;

  @override
  State<LocationInfoContent> createState() => _LocationInfoContentState();
}

class _LocationInfoContentState extends State<LocationInfoContent> {
  late final loc = widget.loc;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        loc.toggleFavorite();
      },
      child: Container(
        decoration: BoxDecoration(
          color: loc.palette == null ? Colors.black : loc.palette!.color,
          borderRadius: BorderRadius.circular(10),
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
            children: [
              SizedBox(
                child: Image(
                  image: loc.img.image,
                  fit: BoxFit.cover,
                ),
                height: widget.imageHeight,
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * widget.rw),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A row will impose no constraint on its children
                          // unless they are wrapped in an Expanded widget.
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: widget.imageHeight +
                                        widget.separatorHeight *
                                            4), // empty space for image
                                Text(
                                  loc.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: widget.separatorHeight),
                                Text(
                                  loc.type.toChineseString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: widget.separatorHeight),
                                Row(
                                  children: [
                                    for (int i = 1; i <= 5; i++)
                                      Icon(
                                        loc.rate < i
                                            ? Icons.star_border
                                            : Icons.star,
                                        color: Colors.white,
                                      ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                ),
                                SizedBox(height: widget.separatorHeight * 5),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                  height: widget.imageHeight +
                                      widget.separatorHeight * 4),
                              IconButton(
                                icon: Icon(
                                  loc.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    loc.toggleFavorite();
                                  });
                                },
                              ),
                              Text(
                                loc.isFavorite ? '已收藏' : '收藏',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_alt_outlined,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 推荐指数：${loc.heat}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 推荐耗时：${loc.timeCost.toInt().toChineseDurationString()}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money_rounded,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 人均花费：￥${loc.cost.toStringAsFixed(0)} 元",
                            style: Theme.of(context).textTheme.headline3,
                            // style: const TextStyle(
                            //   fontSize: 15,
                            //   color: Colors.white,
                            // ),
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              " ${loc.address}",
                              style: Theme.of(context).textTheme.headline3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityInfoContent extends StatefulWidget {
  const ActivityInfoContent(
    this.act, {
    Key? key,
    required this.imageHeight,
    required this.separatorHeight,
    required this.rw,
  }) : super(key: key);

  final Activity act;
  final double imageHeight;
  final double separatorHeight;
  final double rw;

  @override
  State<ActivityInfoContent> createState() => _ActivityInfoContentState();
}

class _ActivityInfoContentState extends State<ActivityInfoContent> {
  late final loc = widget.act.location;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        loc.toggleFavorite();
      },
      child: Container(
        decoration: BoxDecoration(
          color: loc.palette == null ? Colors.black : loc.palette!.color,
          borderRadius: BorderRadius.circular(10),
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
            children: [
              SizedBox(
                child: Image(
                  image: loc.img.image,
                  fit: BoxFit.cover,
                ),
                height: widget.imageHeight,
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * widget.rw),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A row will impose no constraint on its children
                          // unless they are wrapped in an Expanded widget.
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: widget.imageHeight +
                                        widget.separatorHeight *
                                            4), // empty space for image
                                Text(
                                  loc.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: widget.separatorHeight),
                                Text(
                                  loc.type.toChineseString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: widget.separatorHeight),
                                Row(
                                  children: [
                                    for (int i = 1; i <= 5; i++)
                                      Icon(
                                        loc.rate < i
                                            ? Icons.star_border
                                            : Icons.star,
                                        color: Colors.white,
                                      ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.start,
                                ),
                                SizedBox(height: widget.separatorHeight * 5),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                  height: widget.imageHeight +
                                      widget.separatorHeight * 4),
                              IconButton(
                                icon: Icon(
                                  loc.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    loc.toggleFavorite();
                                  });
                                },
                              ),
                              Text(
                                loc.isFavorite ? '已收藏' : '收藏',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.watch,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 预计到达：${widget.act.startTime.toChineseString()} ${widget.act.startTime.toString().substring(11, 16)}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.watch_later_outlined,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 预计耗时：${widget.act.duration.toChineseDurationString()}",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money_rounded,
                            color: Colors.white,
                            // size: 20,
                          ),
                          Text(
                            " 预计花费：￥${widget.act.cost.toStringAsFixed(0)} 元",
                            style: Theme.of(context).textTheme.headline3,
                            // style: const TextStyle(
                            //   fontSize: 15,
                            //   color: Colors.white,
                            // ),
                          ),
                        ],
                      ),
                      SizedBox(height: widget.separatorHeight),
                      Row(
                        children: [
                          const Icon(
                            Icons.pin_drop_outlined,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: Text(
                              " ${loc.address}",
                              style: Theme.of(context).textTheme.headline3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.act.remarks != '')
                Positioned(
                  top: 10,
                  right: 10,
                  child: SizedBox(
                    height: 150 * widget.rw,
                    width: 150 * widget.rw,
                    child: StickyNote(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13.0, right: 4.0),
                        child: Text(
                          widget.act.remarks,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'AaManYuShouXieTi',
                            fontSize: 15,
                          ),
                          maxLines: 5,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // color: loc.palette!.color.lighten(),
                      // color: loc.palette!.color,
                      color: Colors.yellow,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackSideContent extends StatelessWidget {
  const BackSideContent({
    required this.loc,
    required this.separatorHeight,
    required this.rw,
    Key? key,
  }) : super(key: key);

  final Location loc;
  final double separatorHeight;
  final double rw;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: loc.palette == null ? Colors.black : loc.palette!.color,
        borderRadius: BorderRadius.circular(10),
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
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * rw, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A row will impose no constraint on its children
                      // unless they are wrapped in an Expanded widget.
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.name,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: separatorHeight),
                            Text(
                              loc.type.toChineseString(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: separatorHeight),
                            Row(
                              children: [
                                for (int i = 1; i <= 5; i++)
                                  Icon(
                                    loc.rate < i
                                        ? Icons.star_border
                                        : Icons.star,
                                    color: Colors.white,
                                  ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.start,
                            ),
                            SizedBox(height: separatorHeight * 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: separatorHeight),
                  // 开放时间
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          // size: 20,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "开放时间：${loc.opentime}",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: separatorHeight),
                  // 地址
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.pin_drop_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          loc.address,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ],
                  ),
                  // 标签
                  if (loc.label.isNotEmpty)
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.label_outline,
                            color: Colors.white,
                          ),
                        ),
                        Wrap(
                          children: List.generate(loc.label.length, (index) {
                            return Row(
                              children: [
                                SizedBox(width: 4 * rw),
                                Container(
                                  height: 19,
                                  width:
                                      13.0 * loc.type.toChineseString().length,
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  child: FittedBox(
                                      child: Text(loc.type.toChineseString())),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 25.0),
                    child: DashLineSeparator(color: Colors.white60),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (loc.description != '')
                            Column(
                              children: [
                                Center(
                                  child: InfoHeaderLabel(
                                    text: '地点介绍',
                                    rw: rw,
                                    loc: loc,
                                  ),
                                ),
                                Text(
                                  loc.description,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                const SizedBox(height: 25), // padding
                              ],
                            ),
                          Center(
                            child: InfoHeaderLabel(
                              text: '位置',
                              rw: rw,
                              loc: loc,
                            ),
                          ),
                          // TODO: replace with map
                          const SizedBox(
                            height: 250,
                            child: Placeholder(
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: InfoHeaderLabel(
                              text: '链接',
                              rw: rw,
                              loc: loc,
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                            child: Placeholder(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoHeaderLabel extends StatelessWidget {
  const InfoHeaderLabel({
    Key? key,
    required this.text,
    required this.rw,
    required this.loc,
  }) : super(key: key);

  final double rw;
  final Location loc;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 23),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white60,
              Colors.transparent,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: SizedBox(
            height: 4,
            width: 50 * rw,
          ),
        ),
        const SizedBox(height: 10), // trailing padding
      ],
    );
  }
}
