import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../provider/agent_provider/post_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/main_provider.dart';
import '../../../settings/constants.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
class ImageView extends StatefulWidget {
  const ImageView({Key? key, this.index = 0}) : super(key: key);
  final int index;
  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  PageController pageController = PageController(initialPage: 0);
  bool delete = false ;
  int currentpage=0;


  @override
  Widget build(BuildContext context) {
    var authprovider = Provider.of<AuthProvider>(context, listen: false);
    var listingprovider = Provider.of<MainProvider>(context, listen: true);
    var postprovider = Provider.of<PostProvider>(context, listen: true);

    void onDelete(){
      setState(() {
        delete = true;
      });
      Future.delayed(Duration(milliseconds: 500), (){
        postprovider.removeImage(currentpage);

      });
      setState(() {
        delete = false;
      });

    }


    return Scaffold(
      backgroundColor: listingprovider.getBackgroundColor(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: listingprovider.getBackgroundColor(),
        leading: IconButton(

          color: listingprovider.getForegroundColor(),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left, size: 40,),
        ),
        title: Text("Pictures",
        style: TextStyle(
          color: listingprovider.getForegroundColor()
          ),
        ),


      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          postprovider.imageFiles.isEmpty?

          Container(
            // margin: EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("NO IMAGES",
                style: TextStyle(
                  color: listingprovider.getForegroundColor()
                ),
              ),
            ),
          ):
          Stack(
            children: [
              Container(
                // margin: EdgeInsets.only(top: 20),
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: postprovider.imageFiles.length,
                  onPageChanged: (int value){
                    print(value);
                    setState(() {
                      currentpage = value;
                    });



                  },
                  itemBuilder: (context, index){
                    // transformationController: TransformationController();

                    return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // image: DecorationImage(
                          //   fit: BoxFit.contain,
                          //   image: FileImage(File(postprovider.imageFiles[index]),
                          //   ),
                          // ),
                        ),
                      child: PinchZoom(
                          resetDuration: const Duration(milliseconds: 100),
                    // maxScale: 2.5,
                    onZoomStart: (){print('Start zooming');},
                    onZoomEnd: (){print('Stop zooming');},
                        child: Image(
                          fit: BoxFit.contain,
                          image: FileImage(File(postprovider.imageFiles[index],


                          ),

                        ),
                      )



                    )
                    );
                  },

                ),
              ),
              Positioned(
                top: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: delete? Colors.redAccent.shade100: Colors.transparent,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        onDelete();
                      },
                      icon: Icon(Icons.delete, color: Colors.red,),
                    ),
                  )
              )
            ],
          ),
          if(postprovider.imageFiles.length>1)
          Container(
            width: MediaQuery.of(context).size.width/2,
            child: Center(

              child: SmoothPageIndicator(
                controller: pageController,
                count:  postprovider.imageFiles.length,

                effect: JumpingDotEffect(
                  radius: 10,
                  activeDotColor: Constants.primaryColor,
                  dotColor: listingprovider.lightMode? Constants.greyColor : listingprovider.getForegroundColor(),
                  dotHeight: 7,
                  dotWidth: 7,
                  jumpScale: .7,
                  verticalOffset: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
