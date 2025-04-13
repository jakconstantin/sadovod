class UsersInfo
{
  late int _userCount;
  final double _price;
  final int _orderCount;
  late double _totalPrice = 0;


  int get userCount =>_userCount;
  void set userCount(int value) {
    if (value != null) {
      _userCount = value;
    }
  }

  double get price =>_price;
  int get orderCount =>_orderCount;

  double get totalPrice =>_totalPrice;
  void set totalPrice(double value) {
    if (value != null) {
      _totalPrice = value;
    }
  }

  late double _totalProfit = 0;
  double get totalProfit =>_totalProfit;
  void set totalProfit(double value) {
    if (value != null) {
      _totalProfit = value;
    }
  }

  late double _paidAmount = 0;
  double get paidAmount =>_paidAmount;
  void set paidAmount(double value) {
    if (value != null) {
      _paidAmount = value;
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

  late double _salaryBroker = 0;
  double get salaryBroker =>_salaryBroker;
  void set salaryBroker(double value) {
    if (value != null) {
      _salaryBroker = value;
    }
  }

  late double _ourIncome = 0;
  double get ourIncome =>_ourIncome;
  void set ourIncome(double value) {
    if (value != null) {
      _ourIncome = value;
    }
  }


  UsersInfo(this._price, this._userCount, this._orderCount);

}


/*
final int _id;
final String _title;
final int _parentID;
final int _img;

int get id => _id;
String get title => _title;
int get parentID => _parentID;
int get img =>_img;

Category(this._id, this._title, this._parentID, this._img);

*/
