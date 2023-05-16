import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';

class ListDummyScreen extends StatefulWidget {
  const ListDummyScreen({Key? key}) : super(key: key);

  @override
  State<ListDummyScreen> createState() => _ListDummyScreenState();
}

class _ListDummyScreenState extends State<ListDummyScreen> {
  @override
  Widget build(BuildContext context) {
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    Color color= listingprovider.lightMode? Color(0xFFF6F6F6): Colors.lightBlue.withOpacity(0.1);

    return Container(
      height: 270,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context,index){




            return Container(
              margin: EdgeInsets.all(5),
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: color,

                  borderRadius: BorderRadius.circular(18)
              ),

            ) ;

          }
      ),
    );;
  }
}
