class OrderPrms
{
  late int _isPaid;

  int get isPaid =>_isPaid;
  void set isPaid(int value) {
    if (value != null) {
      _isPaid = value;
    }
  }

  late int _isBooked;

  int get isBooked =>_isBooked;
  void set isBooked(int value) {
    if (value != null) {
      _isBooked = value;
    }
  }

  late int _isInFact;

  int get isInFact =>_isInFact;
  void set isInFact(int value) {
    if (value != null) {
      _isInFact = value;
    }
  }

  late String _dateCreate;

  String get dateCreate =>_dateCreate;
  void set dateCreate(String value) {
    if (value != null) {
      _dateCreate = value;
    }
  }

  late int _isWroteToSeller;
  int get isWroteToSeller =>_isWroteToSeller;
  void set isWroteToSeller(int value) {
    if (value != null) {
      _isWroteToSeller = value;
    }
  }


  late String _userName;
  String get userName =>_userName;
  void set userName(String value) {
    if (value != null) {
      _userName = value;
    }
  }

  late String _authUserEmail;
  String get authUserEmail =>_authUserEmail;
  void set authUserEmail(String value) {
    if (value != null) {
      _authUserEmail = value;
    }
  }


  late int _isNothingWasFille;
  int get isNothingWasFille =>_isNothingWasFille;
  void set isNothingWasFille(int value) {
    if (value != null) {
      _isNothingWasFille = value;
    }
  }

  int _isPacked = 0;
  int get isPacked =>_isPacked;
  void set isPacked(int value) {
    if (value != null) {
      _isPacked = value;
    }
  }

  void clearPrms()
  {
    _isBooked = 0;
    _isPaid = 0;
    _isInFact = 0;
    _dateCreate = '';
    _isWroteToSeller = 0;
    _userName = '';
    _authUserEmail = '';
    _isNothingWasFille = 0;
    _isPacked = 0;
  }



  //paid': widget._isPaid,
  //'booked': widget._booked
}