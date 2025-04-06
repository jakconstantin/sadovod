class OrdersInfo
{
  late int _orderCount;
  int get orderCount =>_orderCount;
  void set orderCount(int value) {
    if (value != null) {
      _orderCount = value;
    }
  }

  late double _totalPrice = 0;
  double get totalPrice =>_totalPrice;
  void set totalPrice(double value) {
    if (value != null) {
      _totalPrice = value;
    }
  }

  late double _paidInFact = 0;
  double get paidInFact =>_paidInFact;
  void set paidInFact(double value) {
    if (value != null) {
      _paidInFact = value;
    }
  }

  late double _priceAll = 0;
  double get priceAll =>_priceAll;
  void set priceAll(double value) {
    if (value != null) {
      _priceAll = value;
    }
  }

}