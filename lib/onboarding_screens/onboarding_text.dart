import 'package:flutter/material.dart';
import '../provider/main_provider.dart';

class OnboardingText extends StatelessWidget {
  const OnboardingText({
    super.key,
    required this.listingprovider,
    required this.title,
    required this.subtitle
  });

  final MainProvider listingprovider;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: listingprovider.getForegroundColor()
          ),
        ),

        Text(subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: listingprovider.getForegroundColor()

          ),
        ),
      ],
    );
  }
}
