import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/main_provider.dart';

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({Key? key}) : super(key: key);

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  @override
  Widget build(BuildContext context) {
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    return Container(
      child: Column(
        children: [
          Image(
            image: AssetImage(
              "assets/images/empty-folder.png",
            ),
            width: 100,
            height: 100,
            color: listingprovider.getForegroundColor(),
          ),
          Center(
              child: Text(
            'This category \n\n has no items yet !',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: listingprovider.getForegroundColor(),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          )),
        ],
      ),
    );
  }
}
