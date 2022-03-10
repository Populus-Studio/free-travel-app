import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../helpers/sticky_note.dart';
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
  final String? remarks;

  LargeCard(
    this.maxHeight,
    this.rw, {
    Key? key,
    required this.w,
    String? heroTag,
    this.location,
    this.remarks,
  })  : _heroTag = heroTag,
        super(key: key) {
    imageHeight = maxHeight * 0.4;
    separatorHeight = maxHeight * 0.005;
  }

  @override
  State<LargeCard> createState() => _LargeCardState();
}

class _LargeCardState extends State<LargeCard> {
  @override
  Widget build(BuildContext context) {
    late final Location loc;
    if (widget.location != null) {
      loc = widget.location!;
    } else {
      // Here is the receiver of the Location Provider.
      loc = Provider.of<Location>(context, listen: true);
    }
    final largeCard = Container(
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
                          " 推荐耗时：${loc.timeCost.toStringAsFixed(0)}分钟",
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
            if (widget.remarks != null)
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
                        widget.remarks!,
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
    );

    if (widget._heroTag != null) {
      return Hero(
        tag: widget._heroTag!,
        child: Material(
          child: SizedBox(
            height: widget.maxHeight,
            width: widget.w * 0.9,
            child: largeCard,
          ),
          elevation: 2,
          color: Colors.transparent,
        ),
      );
    } else {
      return largeCard;
    }
  }
}
