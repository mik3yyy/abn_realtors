import 'package:flutter/material.dart';

import '../provider/main_provider.dart';
import '../settings/constants.dart';

class ButtonTile extends StatelessWidget {
  const ButtonTile({
    super.key,
    required this.listingprovider,
    required this.title,
    required this.leading,
    required this.traling,
    required this.onTap,
  });

  final MainProvider listingprovider;
  final String title;
  final Icon leading;
  final Icon traling;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Constants.primaryColor)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: ListTile(
            minVerticalPadding: 0.0,
            leading: leading,
            title: Text(
              title,
              style: TextStyle(color: listingprovider.getForegroundColor()),
            ),
            trailing: traling,
          ),
        ),
      ),
    );
  }
}
