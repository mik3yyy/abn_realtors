import 'package:abn_realtors/settings/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
class MainProvider with ChangeNotifier {
  // final GlobalKey<ScaffoldMessengerState> customerScaffoldKey =
  // GlobalKey<ScaffoldMessengerState>();
  // final GlobalKey<ScaffoldMessengerState> agentScaffoldKey =
  // GlobalKey<ScaffoldMessengerState>();



  bool darkmode = SystemTheme.isDarkMode;
  Color _backgroudColor = Constants.lightColor;
  bool lightMode =  true;
  bool init = true;

  bool bottomSheetYesProcessing = false;

  void changeMode(){
    lightMode =!lightMode;
    notifyListeners();
  }
  Color getBackgroundColor (){
    if(darkmode && init){
      _backgroudColor = Constants.darkColor;
      lightMode = false;
      init = false;
    }

    return _backgroudColor;
  }
  Color getForegroundColor (){
    if (_backgroudColor == Constants.lightColor){
      return Constants.darkColor;
    } else{
      return Constants.lightColor;
    }


  }
  void changeBackgroundColor(){
    changeMode();
    if (_backgroudColor == Constants.lightColor){
      _backgroudColor = Constants.darkColor;
    } else{
      _backgroudColor = Constants.lightColor;
    }
    notifyListeners();
  }
  TextStyle getTextStyle() {


    return TextStyle(

        color: getForegroundColor()

    );
  }

}