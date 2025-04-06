import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/view/order_widget.dart';
import 'package:sadovod/view/use_checked_widget.dart';
import 'package:sadovod/view/use_packed_widget.dart';
import 'package:sadovod/view/utils.dart';
import '../models/order_prms.dart';
import '../models/orders_info.dart';
import '../models/supabase_service.dart';
import 'checkbox_widget.dart';
import 'orders_top_panel_widget.dart';

class UserPage extends StatefulWidget {
  final String _dateId;
  final String _userId;
  final String _userName;
  final int _userPercent;
  final int _useChecked;
  final bool _isVisibleChecked;

  UserPage({
    Key? key,
    required String dateId,
    required String userId,
    required String userName,
    required int userPercent,
    required int useChecked,
    required bool isVisibleChecked,
  })  : _dateId = dateId,
        _userId = userId,
        _userName = userName,
        _userPercent = userPercent,
        _useChecked = useChecked,
        _isVisibleChecked = isVisibleChecked,
        super(key: key) {
    print('dateId: $dateId, userId: $userId, userPercent: $userPercent');
  }

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final supabase = SupabaseService().supabase;
  final TextEditingController _nameUserController = TextEditingController();
  final TextEditingController _nameOrderController = TextEditingController();
  final TextEditingController _priceOrderController = TextEditingController();
  final TextEditingController _countOrderController = TextEditingController();
  final TextEditingController _urlOrderController = TextEditingController();
  final TextEditingController _descriptionOrderController = TextEditingController();
  final TextEditingController _commentOrderController = TextEditingController();
  final OrderPrms _orderPrms = OrderPrms();

  @override
  void dispose() {
    _nameUserController.dispose();
    _nameOrderController.dispose();
    _priceOrderController.dispose();
    _countOrderController.dispose();
    _urlOrderController.dispose();
    _descriptionOrderController.dispose();
    _commentOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(widget._userName),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить заказ',
        onPressed: () {
          _createOrder();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTitle(String userName) {
    _nameUserController.text = userName;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text('Заказы  $userName'),
          ),
          IconButton(
            onPressed: () {
              if (_nameUserController.text.trim().isNotEmpty) {
                FlutterClipboard.copy(_nameUserController.text)
                    .then((value) => print('copied text'));
              }
            },
            icon: Icon(Icons.copy),
          ),
          widget._isVisibleChecked
              ? UseCheckedWidget(
            userId: widget._userId,
            useChecked: widget._useChecked,
          )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildBody(context) {
    return StreamBuilder<Object?>(
      stream: supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('userId', widget._userId)
          .order('dateCreate', ascending: false),
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        print('Происходят изменения или нет snapshot.hasData: ${snapshot.hasData}');
        if (snapshot.hasError) {
          print('Ошибка в StreamBuilder: ${snapshot.error}');
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text('Что-то пошло не так ${snapshot.error}'),
              ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text("Загрузка"),
              ),
            ],
          );
        }


        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text("Нет записей!"),
              ),
            ],
          );
        }


        List<Map<String, dynamic>> items;
        try {
          final rawData = snapshot.data as List<dynamic>;
          items = rawData.map((item) {
            final mapItem = item as Map;
            return mapItem.map((key, value) => MapEntry(key.toString(), value));
          }).toList();
        } catch (e) {
          print('Ошибка приведения типов: $e');
          return Center(
            child: Text('Ошибка обработки данных: $e'),
          );
        }

        return Column(
          children: [
            OrdersTopPanelWidget(
              dateId: widget._dateId,
              userId: widget._userId,
              userPercent: widget._userPercent,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final order = items[index];
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(order['id'].toString()),
                    child: Card(
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
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                if (await Utils.alertDialogDelete(context, order['name'])) {
                                  await supabase.from('orders').delete().eq('id', order['id']);
                                }
                              },
                            ),
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
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return await Utils.alertDialogDelete(context, order['name']);
                    },
                    onDismissed: (direction) async {
                      await supabase.from('orders').delete().eq('id', order['id']);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsePackedWidget(Map<String, dynamic> order) {
    int packed = order['packed'] ?? 0;
    return UsePackedWidget(
      usePacked: packed,
      orderId: order['id'],
      onPackedChanged: (value) {
        setState(() {}); // Обновление UI при изменении packed
      },
    );
  }

  Widget _getTitle(int index, Map<String, dynamic> order) {
    String name = order['name'];
    double price = order['price'] ?? 0.0;
    int count = order['count'] ?? 1;
    double priceAll = price * count;
    double priceResult = priceAll + (priceAll * widget._userPercent) / 100;
    bool useComment = (order['comment'] ?? '').toString().isNotEmpty;
    String authUserEmail = order['authUserEmail'] ?? '';

    return Utils.getTitle('', name, price, count, widget._userPercent, useComment, authUserEmail, null, index);
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

  Future<void> _createOrder() async {
    _clearController();
    _orderPrms.dateCreate = DateTime.now().toIso8601String();
    _orderPrms.userName = widget._userName;
    _orderPrms.authUserEmail = SupabaseService().currentUser!.email!;

    await showModalBottomSheet(
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
          false,
          "",
          widget._dateId,
          widget._userId,
          _orderPrms,
        );
      },
    ).then((value) {
      _clearController();
    });
  }

  Future<void> _editeOrder([Map<String, dynamic>? order]) async {
    if (order != null) {
      _nameOrderController.text = order['name'] ?? '';
      _priceOrderController.text = (order['price'] ?? 0).toString();
      _countOrderController.text = (order['count'] ?? 1).toString();
      _urlOrderController.text = order['url'] ?? '';
      _descriptionOrderController.text = order['description'] ?? '';
      _commentOrderController.text = order['comment'] ?? '';
      _orderPrms.isPaid = order['paid'] ?? 0;
      _orderPrms.isBooked = order['booked'] ?? 0;
      _orderPrms.isInFact = order['inFact'] ?? 0;
      _orderPrms.dateCreate = order['dateCreate'] ?? '';
      _orderPrms.isWroteToSeller = order['wroteToSeller'] ?? 0;
      _orderPrms.authUserEmail = order['authUserEmail'] ?? '';
      _orderPrms.isPacked = order['packed'] ?? 0;
    }
    _orderPrms.userName = widget._userName;

    await showModalBottomSheet(
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
          order!['id'],
          widget._dateId,
          widget._userId,
          _orderPrms,
        );
      },
    ).then((value) {
      _clearController();
    });
  }
}