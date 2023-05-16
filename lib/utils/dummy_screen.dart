import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../provider/auth_provider.dart';
import '../provider/main_provider.dart';
import '../settings/constants.dart';

class DummyScreen extends StatefulWidget {
  const DummyScreen({Key? key}) : super(key: key);

  @override
  State<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {

  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);

    Color color= listingprovider.lightMode? Color(0xFFF6F6F6): Colors.lightBlue.withOpacity(0.1);
    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),

      appBar: AppBar(
        backgroundColor: listingprovider.getBackgroundColor(),
        elevation: 0,
        // leadingWidth: 70,
        leading: IconButton(
          onPressed: (){},
          icon: Container(
            // margin: EdgeInsets.only(left: 10),
            width: 40,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.lightBlueAccent.shade100,
                borderRadius: BorderRadius.circular(10)

            ),
            child: Center(
              child: Icon(Icons.notifications_none,color: Constants.primaryColor,),
            ),
          ),
        ),
        title: Container(
          width: MediaQuery.of(context).size.width *0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back',
                style: TextStyle(
                    color:  Colors.grey,
                    fontSize: 10
                ),
              ),
              Text(authprovider.fullname,
                style: TextStyle(
                  fontSize: 15,
                  color:  listingprovider.getForegroundColor(),
                ),
              ),
            ],
          ),
        ),

        actions: [
          Container(
            height: 100,
            width: 60,
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(5),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(50)

                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),


                ),
              ),
            ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width *0.5,
                  height: MediaQuery.of(context).size.height *0.015,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: color,
                  ),

                ),
                Container(
                  margin: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width *0.7,
                  height: MediaQuery.of(context).size.height *0.015,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: color,
                  ),

                ),

              ],
            ),
            StaggeredGridView.countBuilder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 6,
            crossAxisCount: 2,
            itemBuilder: (context, index) {

              return  Container(
                margin: EdgeInsets.all(5),
                height: MediaQuery.of(context).size.height* 0.22,
                decoration: BoxDecoration(
                    color: color,

                    borderRadius: BorderRadius.circular(18)
                ),

              );
            },
            staggeredTileBuilder: (context) => const StaggeredTile.fit(1)),

          ],
        ),
      ),

    );
  }
}
