import 'package:flutter/cupertino.dart';

class CardModel extends ChangeNotifier {

  double _totalPrice = 0;
  double get totalPrice => _totalPrice;

  void add(double price) {
    _totalPrice += price;

    notifyListeners();
  }

  void removeAll() {
    _totalPrice = 0;
    notifyListeners();
  }
}