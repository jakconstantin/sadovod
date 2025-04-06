import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/users_page.dart';
import 'package:sadovod/View/utils.dart';
import 'package:sadovod/view/search_widget.dart';
import '../models/supabase_service.dart';
import 'navigation_drawer_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = SupabaseService().supabase;
  final TextEditingController _namePurchaseController = TextEditingController();
  final TextEditingController _agentPercentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _namePurchaseController.dispose();
    _agentPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Садовод)))'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.red),
              onPressed: () async {
                await supabase.auth.signOut();
                setState(() {});
              },
            ),
          ],
        ),
        drawer: NavigationDrawerWidget(),
        body: StreamBuilder<Object?>(
          stream: supabase
              .from('date_purchases')
              .stream(primaryKey: ['id'])
              .order('dateCreate', ascending: false),
          builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {

            print('Происходят изменения или нет snapshot.hasData: ${snapshot.hasData}');

            if (snapshot.hasError) {
              print('Ошибка в StreamBuilder: ${snapshot.error}');
              return Center(
                child: Text('Что-то пошло не так: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Загрузка"),
              );
            }

            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(
                child: Text("Нет записей"),
              );
            }

            // Безопасное приведение типов
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

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  key: Key(item['id'].toString()),
                  child: Card(
                    child: ListTile(
                      contentPadding: Utils.getEdgeInsetsForCard(),
                      onTap: () => _navigatorPushUsersPage(item['id']),
                      title: _getTitle(item['name'], item['agentpercent']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            icon: Icon(Icons.edit),
                            onPressed: () => _createEditPurchase(item),
                          ),
                          IconButton(
                            padding: Utils.getPaddingIconButton(),
                            onPressed: () => _navigatorPushUsersPage(item['id']),
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
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Добавить закупку',
          onPressed: () => _createEditPurchase(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _navigatorPushUsersPage(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UsersPage(dateId: id)),
    );
  }

  Widget _getTitle(String name, int percent) {
    return Row(
      children: [
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        Text(" $percent%"),
      ],
    );
  }

  Future<void> _delete(String id) async {
    try {
      await supabase.from('orders').delete().eq('dateId', id);
      await supabase.from('users').delete().eq('dateId', id);
      await supabase.from('expenses').delete().eq('dateId', id);
      await supabase.from('incomes').delete().eq('dateId', id);
      await supabase.from('date_purchases').delete().eq('id', id);
    } catch (e) {
      print('Ошибка при удалении: $e');
    }
  }

  Future<void> _createEditPurchase([Map<String, dynamic>? item]) async {
    bool isEdit = item != null;
    _namePurchaseController.text = item?['name'] ?? '';
    _agentPercentController.text = item?['agentpercent']?.toString() ?? '8';

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
                controller: _namePurchaseController,
                decoration: const InputDecoration(labelText: 'Наименование'),
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _agentPercentController,
                decoration: const InputDecoration(labelText: 'Процент посреднику'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: isEdit ? Text('Обновить') : Text('Создать'),
                    onPressed: () async {
                      final String name = _namePurchaseController.text;
                      final int? percent = int.tryParse(_agentPercentController.text);
                      if (percent != null) {
                        try {
                          if (isEdit) {
                            await supabase.from('date_purchases').update({
                              'name': name,
                              'agentpercent': percent,
                            }).eq('id', item!['id']);
                          } else {
                            await supabase.from('date_purchases').insert({
                              'name': name,
                              'agentpercent': percent,
                              'dateCreate': DateTime.now().toIso8601String(),
                            });
                          }
                          _namePurchaseController.clear();
                          _agentPercentController.clear();
                          Navigator.of(context).pop();
                        } catch (e) {
                          print('Ошибка при сохранении закупки: $e');
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
}