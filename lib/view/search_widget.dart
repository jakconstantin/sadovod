import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/view/use_packed_widget.dart';
import 'package:sadovod/view/utils.dart';
import '../models/order_prms.dart';
import '../models/supabase_service.dart';
import 'checkbox_widget.dart';
import 'filter_widget.dart';
import 'order_widget.dart';
import 'orders_page.dart';

class SearchWidget extends StatefulWidget {
  final String _dateId;

  SearchWidget({Key? key, required String dateId})
      : _dateId = dateId,
        super(key: key) {
    print('SearchWidget dateID: $dateId');
  }

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final supabase = SupabaseService().supabase;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameOrderController = TextEditingController();
  final TextEditingController _priceOrderController = TextEditingController();
  final TextEditingController _countOrderController = TextEditingController();
  final TextEditingController _urlOrderController = TextEditingController();
  final TextEditingController _descriptionOrderController = TextEditingController();
  final TextEditingController _commentOrderController = TextEditingController();
  final OrderPrms _orderPrms = OrderPrms();
  final OrderPrms _orderFilterPrms = OrderPrms();

  List<Map<String, dynamic>> _listData = [];
  bool _isLoad = false;
  bool _isError = false;

  @override
  void dispose() {
    _textController.dispose();
    _nameOrderController.dispose();
    _priceOrderController.dispose();
    _countOrderController.dispose();
    _urlOrderController.dispose();
    _descriptionOrderController.dispose();
    _commentOrderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _orderFilterPrms.clearPrms();
  }

  void _clearController() {
    _nameOrderController.text = '';
    _priceOrderController.text = '0';
    _countOrderController.text = '1';
    _urlOrderController.text = '';
    _descriptionOrderController.text = '';
    _commentOrderController.text = '';
    _orderPrms.clearPrms();
  }

  Future<void> _loadOrders() async {
    try {
      final ordersResponse = await supabase
          .from('orders')
          .select()
          .eq('dateId', widget._dateId)
          .order('userId', ascending: true);

      final usersResponse = await supabase
          .from('users')
          .select()
          .eq('dateId', widget._dateId);

      _listData.clear();
      for (var order in ordersResponse) {
        final user = usersResponse.firstWhere((u) => u['id'] == order['userId']);
        order['userName'] = user['name'];
        order['userPercent'] = user['percent'];
        order['checked'] = user['checked'] ?? 0;
        _listData.add(Map<String, dynamic>.from(order));
      }
    } catch (ex) {
      _isError = true;
      print('Ошибка загрузки данных: $ex');
    }

    _isLoad = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getSearchRow(context),
        actions: [
          IconButton(
            icon: Icon(Icons.filter),
            onPressed: () {
              _buildFilter();
            },
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoad) {
      if (_isError) {
        return Text('Ошибка получения данных');
      }

      List<Map<String, dynamic>> orders = _listData.where((element) {
        final searchText = _textController.text.toLowerCase();
        return element['name'].toLowerCase().contains(searchText) ||
            element['comment'].toLowerCase().contains(searchText) ||
            element['description'].toLowerCase().contains(searchText) ||
            element['userName'].toLowerCase().contains(searchText);
      }).toList();

      if (_orderFilterPrms.isPaid != 0 ||
          _orderFilterPrms.isBooked != 0 ||
          _orderFilterPrms.isInFact != 0 ||
          _orderFilterPrms.isWroteToSeller != 0) {
        orders = orders.where((element) {
          if (_orderFilterPrms.isPaid == 1 && element['paid'] == 1) return true;
          if (_orderFilterPrms.isBooked == 1 && element['booked'] == 1) return true;
          if (_orderFilterPrms.isInFact == 1 && element['inFact'] == 1) return true;
          if (_orderFilterPrms.isWroteToSeller == 1 &&
              element['wroteToSeller'] == 1 &&
              element['paid'] == 0 &&
              element['booked'] == 0 &&
              element['inFact'] == 0) return true;
          if (element['paid'] == 0 &&
              element['booked'] == 0 &&
              element['inFact'] == 0 &&
              element['wroteToSeller'] == 0 &&
              _orderFilterPrms.isNothingWasFille == 1) return true;
          return false;
        }).toList();
      }

      if (_orderFilterPrms.isPacked != 0) {
        orders = orders.where((element) {
          int packed = element['packed'] ?? 0;
          return _orderFilterPrms.isPacked == 1 && packed == 0;
        }).toList();
      }

      return Column(
        children: [
          _buildTopPanel(orders.length),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (BuildContext context, int index) {
                final order = orders[index];
                return Card(
                  color: Utils.getColorStatus(
                    order['paid'],
                    order['booked'],
                    order['inFact'],
                    order['wroteToSeller'],
                  ),
                  child: ListTile(
                    contentPadding: Utils.getEdgeInsetsForCard(),
                    onTap: () {
                      _editeOrder(order);
                    },
                    title: _getTitle(index, order),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: Utils.getPaddingIconButton(),
                          onPressed: () {
                            _editeOrder(order);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        _buildUsePackedWidget(order),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [CircularProgressIndicator()],
      );
    }
  }

  Widget _buildUsePackedWidget(Map<String, dynamic> element) {
    int packed = element['packed'] ?? 0;
    return UsePackedWidget(
      usePacked: packed,
      orderId: element['id'],
      onPackedChanged: (value) async {
        element['packed'] = value;
        await supabase.from('orders').update({'packed': value}).eq('id', element['id']);
        setState(() {}); // Обновление UI после изменения packed
      },
    );
  }

  Widget _buildTopPanel(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Text('Всего заказов: $count'),
    );
  }

  Widget _getTitle(int index, Map<String, dynamic> element) {
    double price = element['price'] ?? 0.0;
    int count = element['count'] ?? 1;
    int userPercent = element['userPercent'] ?? 0;
    double priceAll = price * count;
    double priceResult = priceAll + (priceAll * userPercent) / 100;
    bool useComment = (element['comment'] ?? '').toString().isNotEmpty;
    String authUserEmail = element['authUserEmail'] ?? '';
    int checked = element['checked'] ?? 0;
    String userId = element['userId'];

    Function() onUserPressed = () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserPage(
            userId: userId,
            dateId: widget._dateId,
            userName: element['userName'],
            userPercent: userPercent,
            useChecked: checked,
            isVisibleChecked: false,
          ),
        ),
      ).then((value) => setState(() {}));
    };

    return Utils.getTitle(
      element['userName'],
      element['name'],
      price,
      count,
      userPercent,
      useComment,
      authUserEmail,
      onUserPressed,
      index,
    );
  }

  Future<void> _editeOrder(Map<String, dynamic> element) async {
    _nameOrderController.text = element['name'] ?? '';
    _priceOrderController.text = (element['price'] ?? 0).toString();
    _countOrderController.text = (element['count'] ?? 1).toString();
    _urlOrderController.text = element['url'] ?? '';
    _descriptionOrderController.text = element['description'] ?? '';
    _commentOrderController.text = element['comment'] ?? '';
    _orderPrms.isBooked = element['booked'] ?? 0;
    _orderPrms.isPaid = element['paid'] ?? 0;
    _orderPrms.isInFact = element['inFact'] ?? 0;
    _orderPrms.dateCreate = element['dateCreate'] ?? '';
    _orderPrms.isWroteToSeller = element['wroteToSeller'] ?? 0;
    _orderPrms.authUserEmail = element['authUserEmail'] ?? '';
    _orderPrms.isPacked = element['packed'] ?? 0;
    _orderPrms.userName = element['userName'] ?? '';

    var result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return OrderWidget(
          _nameOrderController,
          _priceOrderController,
          _countOrderController,
          _urlOrderController,
          _descriptionOrderController,
          _commentOrderController,
          true,
          element['id'],
          widget._dateId,
          element['userId'],
          _orderPrms,
        );
      },
    );

    if (result == true) {
      element['name'] = _nameOrderController.text;
      element['price'] = double.tryParse(_priceOrderController.text) ?? 0.0;
      element['count'] = int.tryParse(_countOrderController.text) ?? 1;
      element['url'] = _urlOrderController.text;
      element['description'] = _descriptionOrderController.text;
      element['comment'] = _commentOrderController.text;
      element['paid'] = _orderPrms.isPaid;
      element['booked'] = _orderPrms.isBooked;
      element['inFact'] = _orderPrms.isInFact;
      element['wroteToSeller'] = _orderPrms.isWroteToSeller;
      element['packed'] = _orderPrms.isPacked;
      setState(() {}); // Обновление UI после редактирования
    }

    _clearController();
  }

  Widget _getSearchRow(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Stack(
            alignment: const Alignment(1.0, 1.0),
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Поиск",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _textController.clear();
                      });
                    },
                  )
                      : null,
                ),
                onChanged: (text) {
                  setState(() {});
                },
                onFieldSubmitted: (text) {
                  print('onFieldSubmitted text: $text');
                },
                controller: _textController,
                textInputAction: TextInputAction.search,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Отмена",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _buildFilter() async {
    var result = await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return FilterWidget(_orderFilterPrms);
      },
    );

    if (result != null) {
      setState(() {});
    }
  }
}