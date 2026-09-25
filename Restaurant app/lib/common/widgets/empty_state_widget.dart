import 'package:flutter/material.dart';
import 'package:paustik_poornahar_restaurant/util/dimensions.dart';
import 'package:paustik_poornahar_restaurant/util/images.dart';
import 'package:paustik_poornahar_restaurant/util/styles.dart';

/// Shared "nothing here yet" view: pale green box, bold title, optional hint.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double topPadding;
  const EmptyStateWidget({super.key, required this.title, this.subtitle, this.topPadding = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Opacity(opacity: 0.45, child: Image.asset(Images.emptyBox, height: 90)),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Text(title, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),

            if (subtitle != null) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                subtitle!, textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
