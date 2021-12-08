import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';

class LargeCard extends StatelessWidget {
  // final Location loc;
  final double maxHeight;
  late final imageHeight;
  late final separatorHeight;
  final double rw;

  LargeCard(this.maxHeight, this.rw, {Key? key}) : super(key: key) {
    imageHeight = maxHeight * 0.35;
    separatorHeight = maxHeight * 0.005;
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<Location>(context, listen: false);
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
              decoration: BoxDecoration(color: loc.palette.color),
            ),
            SizedBox(
              child: Image(image: loc.img.image, fit: BoxFit.cover),
              height: imageHeight,
              width: double.infinity,
            ),
            Padding(
              padding: EdgeInsets.only(left: 14.0 * rw),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: imageHeight +
                          separatorHeight), // empty space for image
                  Text(
                    loc.name,
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
                          loc.rate < i ? Icons.star_border : Icons.star,
                          color: Colors.white,
                        ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                  SizedBox(height: separatorHeight * 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        color: Colors.white,
                      ),
                      Text(
                        "人均￥${loc.cost}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: separatorHeight),
                  Row(
                    children: [
                      const Icon(
                        Icons.pin_drop,
                        color: Colors.white,
                      ),
                      Text(
                        loc.address,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
