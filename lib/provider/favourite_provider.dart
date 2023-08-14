import 'package:flutter/foundation.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> products = [];
  bool addorRemoveProduct(String product) {


    if (products.contains(product)) {
      products = products.where((element) => product != element).toList();
      notifyListeners();

      return false;
    } else {
      products.add(product);
      notifyListeners();

      return true;
    }
  }

  void fillData(List<String> newproducts) {
    products = newproducts;
    notifyListeners();
  }
}
