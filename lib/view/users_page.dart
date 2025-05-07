import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/orders_page.dart';
import 'package:sadovod/View/utils.dart';
import 'package:sadovod/view/search_widget.dart';
import 'package:sadovod/view/users_top_panel_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_service.dart';
import 'checkbox_widget.dart';
import 'dropdown_widget.dart';
import 'expenses_widget.dart';
import 'incomes_widget.dart';

class UsersPage extends StatefulWidget {
  final String _dateId;

  UsersPage({Key? key, required String dateId})
      : _dateId = dateId,
        super(key: key) {
    print('dateId: $dateId');
  }

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with WidgetsBindingObserver {
  final supabase = SupabaseService().supabase;
  final TextEditingController _nameUserController = TextEditingController();
  final TextEditingController _percentUserController = TextEditingController();
  final TextEditingController _commentUserController = TextEditingController();
  int _isChecked = 0;
  int _initialScrollIndex = 0;
  final ItemScrollController itemScrollController = ItemScrollController();
  RealtimeChannel? _channel;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Регистрируем наблюдатель
    _subscribeToChannel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('AppLifecycleState: $state');
    if (state == AppLifecycleState.resumed) {
      // Приложение вернулось в активный режим
      if (!_isSubscribed) {
        _subscribeToChannel();
      }
    } else if (state == AppLifecycleState.paused) {
      // Приложение ушло в фоновый режим
      _unsubscribeFromChannel();
    }
  }

  void _subscribeToChannel() {
    // Удаляем старую подписку, если она существует
    _unsubscribeFromChannel();

    // Создаем новый канал
    _channel = supabase.channel('public:users');
    _channel!.subscribe((status, [error]) async {
      print('Subscription status: $status, error: $error');
      if (status == RealtimeSubscribeStatus.subscribed) {
        setState(() {
          _isSubscribed = true;
        });
        print('Subscribed to users channel');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        setState(() {
          _isSubscribed = false;
        });
        print('Channel error: $error. Retrying in 5 seconds...');
        await Future.delayed(Duration(seconds: 5));
        if (mounted) {
          _subscribeToChannel(); // Повторная попытка подписки
        }
      } else if (status == RealtimeSubscribeStatus.closed) {
        setState(() {
          _isSubscribed = false;
        });
        print('Channel closed. Attempting to reconnect...');
        if (mounted) {
          _subscribeToChannel();
        }
      }
    });
  }

  void _unsubscribeFromChannel() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
      _channel = null;
      setState(() {
        _isSubscribed = false;
      });
      print('Unsubscribed from channel');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Удаляем наблюдатель
    _unsubscribeFromChannel();
    _nameUserController.dispose();
    _percentUserController.dispose();
    _commentUserController.dispose();
    super.dispose();
  }

  void _searchRun() {
    _initialScrollIndex = 0;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchWidget(dateId: widget._dateId)),
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Заказчики'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchRun,
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить заказчика',
        onPressed: _createEditUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('dateId', widget._dateId)
          .order('dateCreate', ascending: false),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        print('StreamBuilder snapshot.hasData: ${snapshot.hasData}, connectionState: ${snapshot.connectionState}');

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}, stackTrace: ${snapshot.stackTrace}');
          return Center(
            child: Text('Ошибка: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("Нет записей"),
          );
        }

        final items = snapshot.data!;

        return Column(
          children: [
            UsersTopPanelWidget(dateId: widget._dateId),
            Card(
              child: ListTile(
                contentPadding: Utils.getEdgeInsetsForCard(),
                title: _getTitleExpenses(),
                onTap: _navigatorPushExpensesWidget,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: Utils.getPaddingIconButton(),
                      onPressed: _navigatorPushExpensesWidget,
                      icon: Icon(CupertinoIcons.forward),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: _getTitleIncomes(),
                contentPadding: Utils.getEdgeInsetsForCard(),
                onTap: _navigatorPushIncomesWidget,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: Utils.getPaddingIconButton(),
                      onPressed: _navigatorPushIncomesWidget,
                      icon: Icon(CupertinoIcons.forward),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            const SizedBox(height: 5),
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemCount: items.length,
                initialScrollIndex: _initialScrollIndex,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(item['id'].toString()),
                    child: Card(
                      color: _getColorStatus(item),
                      child: ListTile(
                        contentPadding: Utils.getEdgeInsetsForCard(),
                        title: _getTitle(item['name'], item['percent']),
                        onTap: () => _navigatorPushUserPage(item, index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _getComment(item),
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                if (await Utils.alertDialogDelete(context, item['name'])) {
                                  await _delete(item['id']);
                                }
                              },
                            ),
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              onPressed: () => _createEditUser(item: item),
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              onPressed: () => _navigatorPushUserPage(item, index),
                              icon: Icon(CupertinoIcons.forward),
                            ),
                          ],
                        ),
                      ),
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return await Utils.alertDialogDelete(context, item['name']);
                    },
                    onDismissed: (direction) async {
                      await _delete(item['id']);
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

  Widget _getComment(Map<String, dynamic> item) {
    bool isComment = item.containsKey('comment') && item['comment'].toString().isNotEmpty;
    return IconButton(
      onPressed: () => _createEditUser(item: item),
      icon: Utils.getIconComment(isComment),
    );
  }

  void _navigatorPushExpensesWidget() {
    _initialScrollIndex = 0;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensesWidget(dateId: widget._dateId)),
    ).then((value) => setState(() {}));
  }

  void _navigatorPushIncomesWidget() {
    _initialScrollIndex = 0;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IncomesWidget(dateId: widget._dateId)),
    ).then((value) => setState(() {}));
  }

  void _navigatorPushUserPage(Map<String, dynamic> item, int index) {
    int checked = item.containsKey('checked') ? item['checked'] : 0;
    _initialScrollIndex = index;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPage(
          userId: item['id'],
          dateId: widget._dateId,
          userName: item['name'],
          userPercent: item['percent'],
          useChecked: checked,
          isVisibleChecked: true,
        ),
      ),
    ).then((value) => setState(() {}));
  }

  Future<void> _createEditUser({Map<String, dynamic>? item}) async {
    bool isEdit = item != null;
    if (isEdit) {
      _nameUserController.text = item!['name'];
      _percentUserController.text = item['percent'].toString();
      _commentUserController.text = item.containsKey('comment') ? item['comment'] : '';
      _isChecked = item.containsKey('checked') ? item['checked'] : 0;
    } else {
      _nameUserController.text = '';
      _percentUserController.text = '20';
      _commentUserController.text = '';
      _isChecked = 0;
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    splashRadius: 24.0,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              TextField(
                controller: _nameUserController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _percentUserController,
                decoration: const InputDecoration(labelText: 'Процент'),
              ),
              TextField(
                controller: _commentUserController,
                decoration: const InputDecoration(labelText: 'Комментарий'),
              ),
              _isCheckedWidget(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: isEdit ? Text('Обновить') : Text('Создать'),
                    onPressed: () async {
                      final String name = _nameUserController.text;
                      final int? percent = int.tryParse(_percentUserController.text);
                      if (percent != null) {
                        try {
                          if (isEdit) {
                            await supabase.from('users').update({
                              'name': name,
                              'percent': percent,
                              'comment': _commentUserController.text,
                              'checked': _isChecked,
                            }).eq('id', item!['id']);
                          } else {
                            await supabase.from('users').insert({
                              'name': name,
                              'dateId': widget._dateId,
                              'percent': percent,
                              'dateCreate': DateTime.now().toIso8601String(),
                              'comment': _commentUserController.text,
                              'checked': _isChecked,
                            });
                          }
                          _nameUserController.clear();
                          _percentUserController.clear();
                          _commentUserController.clear();
                          _isChecked = 0;
                          Navigator.of(context).pop();
                        } catch (e) {
                          print('Ошибка при сохранении пользователя: $e');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _isCheckedWidget() {
    return CheckboxWidget(
      title: 'Все проверено',
      value: _isChecked,
      onSelect: (value) {
        print('isChecked Widget set: $value');
        _isChecked = value;
      },
    );
  }

  Widget _getTitleExpenses() {
    return Row(
      children: [
        Expanded(child: Text('Расходы', overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _getTitleIncomes() {
    return Row(
      children: [
        Expanded(child: Text('Приходы', overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Future<void> _delete(String id) async {
    try {
      await supabase.from('orders').delete().eq('userId', id);
      await supabase.from('users').delete().eq('id', id);
    } catch (e) {
      print('Ошибка при удалении: $e');
    }
  }

  Widget _getTitle(String name, int percent) {
    return Row(
      children: [
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        Text("$percent%"),
      ],
    );
  }

  Color _getColorStatus(Map<String, dynamic> item) {
    return item.containsKey('checked') && item['checked'] == 1 ? Colors.teal : Colors.white;
  }
}