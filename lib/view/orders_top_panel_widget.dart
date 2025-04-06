import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/orders_info.dart';
import '../models/supabase_service.dart';

class OrdersTopPanelWidget extends StatefulWidget {
  final String _dateId;
  final String _userId;
  final int _userPercent;

  OrdersTopPanelWidget({
    Key? key,
    required String dateId,
    required String userId,
    required int userPercent,
  })  : _dateId = dateId,
        _userId = userId,
        _userPercent = userPercent,
        super(key: key) {
    print('dateId: $dateId');
  }

  @override
  _OrdersTopPanelWidgetState createState() => _OrdersTopPanelWidgetState();
}

class _OrdersTopPanelWidgetState extends State<OrdersTopPanelWidget> {
  final supabase = SupabaseService().supabase;
  bool _isViewPanel = false;
  bool _isRefresh = false;
  OrdersInfo? _ordersInfo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2),
          child: TextButton(
            onPressed: () {
              setState(() {
                _isViewPanel = true;
                _ordersInfo = null; // Сбрасываем кэш для обновления данных
                _isRefresh = true;
              });
            },
            child: _isRefresh ? Text('Обновить статистику') : Text('Увидеть статистику'),
          ),
        ),
        _isViewPanel ? _buildViewPanel(context) : Container(),
      ],
    );
  }

  Widget _buildViewPanel(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _getPay(),
          builder: (BuildContext context, AsyncSnapshot<OrdersInfo> asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              _isRefresh = false; // Сбрасываем флаг после успешной загрузки
              return _getTopPanel(asyncSnapshot.data!);
            } else if (asyncSnapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${asyncSnapshot.error}'),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  Future<OrdersInfo> _getPay() async {
    if (_ordersInfo != null) {
      print('ordersInfo not empty');
      return _ordersInfo!;
    }

    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('dateId', widget._dateId)
          .eq('userId', widget._userId);

      int orderCount = 0;
      double priceUser = 0;
      double paidInFact = 0;
      double priceAll = 0;

      for (var order in response) {
        double priceUserReal = (order['price'] ?? 0.0) * (order['count'] ?? 1);
        priceAll += priceUserReal;

        if (order['paid'] == 1) {
          priceUser += priceUserReal;
        } else if (order['inFact'] == 1) {
          paidInFact += priceUserReal;
        }

        orderCount++;
      }

      print('paidInFact: $paidInFact, priceAll: $priceAll');
      OrdersInfo info = OrdersInfo();
      info.orderCount = orderCount;
      info.totalPrice = priceUser;
      info.paidInFact = paidInFact;
      info.priceAll = priceAll;
      _ordersInfo = info;
      return info;
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      rethrow; // Пробрасываем ошибку в FutureBuilder
    }
  }

  Widget _getTopPanel(OrdersInfo ordersInfo) {
    print('get Top Panel value: $ordersInfo');
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        color: Colors.white,
        child: _buildPanel(ordersInfo),
      ),
    );
  }

  Widget _buildPanel(OrdersInfo info) {
    return Column(
      children: [
        GridView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            childAspectRatio: (1 / .4),
          ),
          children: [
            Text("Количество заказов: ${info.orderCount}"),
            Text("Оплачено: ${info.totalPrice}"),
            Text("Оплачено по факту: ${info.paidInFact}"),
            Text("Итог: ${info.paidInFact + info.totalPrice}"),
            Text("Итог с ${widget._userPercent}%: ${info.priceAll + (info.priceAll * widget._userPercent) / 100}"),
          ],
        ),
      ],
    );
  }
}