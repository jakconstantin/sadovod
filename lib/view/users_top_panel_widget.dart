import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/users_info.dart';
import '../models/supabase_service.dart';
import 'package:sadovod/View/utils.dart';

class UsersTopPanelWidget extends StatefulWidget {
  final String _dateId;

  UsersTopPanelWidget({Key? key, required String dateId})
      : _dateId = dateId,
        super(key: key) {
    print('dateId: $dateId');
  }

  @override
  _UsersTopPanelWidgetState createState() => _UsersTopPanelWidgetState();
}

class _UsersTopPanelWidgetState extends State<UsersTopPanelWidget> {
  final supabase = SupabaseService().supabase;
  bool _isViewPanel = false;
  bool _isRefresh = false;
  UsersInfo? _userInfo;

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
                _userInfo = null; // Сбрасываем кэш для обновления данных
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
          builder: (BuildContext context, AsyncSnapshot<UsersInfo> asyncSnapshot) {
            print('builder test: $asyncSnapshot, _isViewPanel: $_isViewPanel');
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

  Future<UsersInfo> _getPay() async {
    print('Start getPay $_userInfo');

    if (_userInfo != null) {
      print('userInfo not empty');
      return _userInfo!;
    }

    try {

      //final надо получить из date_purchase процент
      final purchesResponse =  await supabase.
           from('date_purchases').
           select().
           eq('id', widget._dateId);

      final usersResponse = await supabase
          .from('users')
          .select()
          .eq('dateId', widget._dateId);

      double price = 0;
      double totalPrice = 0;
      int orderCount = 0;
      double paidAmount = 0;
      double paidInFact = 0;
      double priceAll = 0;

      for (var user in usersResponse) {
        String id = user['id'];
        int percent = user['percent'] ?? 0;

        final ordersResponse = await supabase
            .from('orders')
            .select()
            .eq('dateId', widget._dateId)
            .eq('userId', id);

        double priceUser = 0;
        double paidAmountUser = 0;

        for (var order in ordersResponse) {
          double priceUserReal = (order['price'] ?? 0.0) * (order['count'] ?? 1);
          priceUser += priceUserReal;
          price += priceUserReal;
          orderCount += 1;

          if (order['paid'] == 1) {
            paidAmountUser += priceUserReal;
          }
          if (order['inFact'] == 1) {
            paidInFact += priceUserReal;
          }
        }

        paidAmount += paidAmountUser;
        priceAll += priceUser + ((priceUser * percent) / 100);
      }

      UsersInfo info = UsersInfo(price, usersResponse.length, orderCount);
      info.totalProfit = totalPrice;
      info.paidAmount = paidAmount;
      info.paidInFact = paidInFact;
      info.priceAll = Utils.roundDouble(priceAll, 2);
      info.salaryBroker = Utils.roundDouble(((info.paidInFact + info.paidAmount)*purchesResponse.elementAt(0)['agentpercent'] )/100, 2);
      info.ourIncome = Utils.roundDouble( ((info.paidInFact + info.paidAmount)* (20-purchesResponse.elementAt(0)['agentpercent']))/100 ,2);
      print('userInfo empty');
      _userInfo = info;
      return info;
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      rethrow; // Пробрасываем ошибку в FutureBuilder
    }
  }

  Widget _getTopPanel(UsersInfo usersInfo) {
    print('get Top Panel value: $usersInfo');
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        color: Colors.white,
        child: _buildPanel(usersInfo),
      ),
    );
  }

  Widget _buildPanel(UsersInfo info) {
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
            Text("Количество заказчиков: ${info.userCount}"),
            Text("Количество заказов: ${info.orderCount}"),
            Text("Оплачено: ${info.paidAmount}"),
            Text("Оплачено по факту: ${info.paidInFact}"),
            Text("Зарплата посредник: ${info.salaryBroker}"),
            Text("Перевести посреднику: ${info.salaryBroker + info.paidInFact}"),
            Text("Итог: ${info.paidInFact + info.paidAmount}"),
            Text("Итог с %: ${info.priceAll}"),
            Text("Наш доход: ${info.ourIncome}",style: const TextStyle(fontWeight: FontWeight.bold, ),),
          ],
        ),
      ],
    );
  }
}