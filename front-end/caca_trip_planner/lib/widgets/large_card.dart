import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';

class LargeCard extends StatefulWidget {
  // final Location loc;
  final double maxHeight;
  late final double imageHeight;
  late final double separatorHeight;
  final double rw;

  LargeCard(this.maxHeight, this.rw, {Key? key}) : super(key: key) {
    imageHeight = maxHeight * 0.35;
    separatorHeight = maxHeight * 0.005;
  }

  @override
  State<LargeCard> createState() => _LargeCardState();
}

class _LargeCardState extends State<LargeCard> {
  @override
  Widget build(BuildContext context) {
    // Here is the receiver of the Location Provider.
    final loc = Provider.of<Location>(context, listen: true);
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
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color:
                      loc.palette == null ? Colors.black : loc.palette!.color),
            ),
            SizedBox(
              child: Image(
                image: loc.img!.image,
                fit: BoxFit.cover,
              ),
              height: widget.imageHeight,
              width: double.infinity,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * widget.rw),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        " 人均花费：￥${loc.cost.toStringAsFixed(0)}元",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
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
          ],
        ),
      ),
    );
  }
}
