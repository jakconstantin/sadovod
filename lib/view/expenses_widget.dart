import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/utils.dart';
import '../models/card_model.dart';
import '../models/supabase_service.dart';
import 'card_widget.dart';

class ExpensesWidget extends StatefulWidget {
  final String _dateId;

  ExpensesWidget({Key? key, required String dateId})
      : _dateId = dateId,
        super(key: key) {
    print('dateId: $dateId');
  }

  @override
  _ExpensesWidgetState createState() => _ExpensesWidgetState();
}

class _ExpensesWidgetState extends State<ExpensesWidget> {
  final supabase = SupabaseService().supabase;
  final CardModel _cardModel = CardModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Расходы'),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить расход',
        onPressed: () {
          _createAndEditExpense();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(context) {
    return StreamBuilder<Object?>(
      stream: supabase
          .from('expenses')
          .stream(primaryKey: ['id'])
          .eq('dateId', widget._dateId)
          .order('dateCreate', ascending: false),
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
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

        _cardModel.removeAll();
        for (var doc in items) {
          _setPrice(doc['price'] ?? 0.0);
        }

        return Column(
          children: [
            CardWidget(cardModel: _cardModel, title: 'Общий расход'),
            Divider(),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final expense = items[index];
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(expense['id'].toString()),
                    child: Card(
                      child: ListTile(
                        contentPadding: Utils.getEdgeInsetsForCard(),
                        title: _getTitle(expense['name'], expense['price'] ?? 0.0),
                        onTap: () {
                          _createAndEditExpense(expense);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                if (await Utils.alertDialogDelete(context, expense['name'])) {
                                  await _delete(expense['id']);
                                }
                              },
                            ),
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              onPressed: () {
                                _createAndEditExpense(expense);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return await Utils.alertDialogDelete(context, expense['name']);
                    },
                    onDismissed: (direction) async {
                      await _delete(expense['id']);

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

  Widget _getTitle(String name, double price) {
    return Row(
      children: [
        Expanded(
          child: Text(name, overflow: TextOverflow.ellipsis),
        ),
        Text(price.toString()),
      ],
    );
  }

  void _setPrice(double price) {
    _cardModel.add(price);
  }

  Future<void> _createAndEditExpense([Map<String, dynamic>? expense]) async {
    bool isEdit = expense != null;
    String id = expense?['id'] ?? '';
    String dateCreate = expense?['dateCreate'] ?? DateTime.now().toIso8601String();

    if (isEdit) {
      _nameController.text = expense!['name'] ?? '';
      _priceController.text = (expense['price'] ?? 0).toString();
      _commentController.text = expense['comment'] ?? '';
    } else {
      _nameController.text = '';
      _priceController.text = '0';
      _commentController.text = '';
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
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Наименование'),
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Комментарий'),
              ),
              _dateCreateWidget(dateCreate),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: isEdit ? Text('Обновить') : Text('Создать'),
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price = double.tryParse(_priceController.text) ?? 0.0;
                      final String comment = _commentController.text;

                      try {
                        if (isEdit) {
                          await supabase.from('expenses').update({
                            'name': name,
                            'price': price,
                            'comment': comment,
                          }).eq('id', id);
                        } else {
                          await supabase.from('expenses').insert({
                            'name': name,
                            'dateId': widget._dateId,
                            'price': price,
                            'comment': comment,
                            'dateCreate': DateTime.now().toIso8601String(),
                          });
                        }
                        _nameController.clear();
                        _priceController.clear();
                        _commentController.clear();
                        Navigator.of(context).pop();

                      } catch (e) {
                        print('Ошибка при сохранении расхода: $e');
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

  Widget _dateCreateWidget(String dateCreate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Дата создания: $dateCreate',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _delete(String id) async {
    try {
      await supabase.from('expenses').delete().eq('id', id);
    } catch (e) {
      print('Ошибка при удалении: $e');
    }
  }
}