import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location.dart';

class LargeCard extends StatelessWidget {
  // final Location loc;
  final double maxHeight;
  const LargeCard(this.maxHeight, {Key? key}) : super(key: key);

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
            // FIXME: Change color as dominantColor updates.
            Consumer<Location>(
              builder: (ctx, loc, child) => Container(
                  decoration: BoxDecoration(color: loc.dominantColor)),
            ),
            SizedBox(
              child: Image(image: loc.img.image, fit: BoxFit.cover),
              height: maxHeight * 0.35,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: maxHeight * 0.35), // empty space for image
                  Text(
                    loc.name,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: maxHeight * 0.02),
                  Text(
                    // FIXME: Use black color when dominant color is light.
                    loc.type.toChineseString(),
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: maxHeight * 0.02),
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
                  SizedBox(height: maxHeight * 0.02),
                  Row(
                    children: [
                      const Icon(
                        Icons.money,
                        color: Colors.white,
                      ),
                      Text(
                        "人均￥${loc.cost}",
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
