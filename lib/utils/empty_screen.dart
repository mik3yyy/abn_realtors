import 'package:flutter/material.dart';


class EmptyScreen extends StatefulWidget {
  const EmptyScreen({Key? key}) : super(key: key);

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Image(
          image: AssetImage("assets/images/empty-folder.png", ),
          width: 100,
          height: 100,

        ),
        Center(
            child: Text(
              'This category \n\n has no items yet !',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,

                  letterSpacing: 1.5),
            )),
      ],
    );
  }
}
