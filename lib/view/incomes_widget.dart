import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/utils.dart';
import '../models/card_model.dart';
import '../models/supabase_service.dart';
import 'card_widget.dart';

class IncomesWidget extends StatefulWidget {
  final String _dateId;

  IncomesWidget({Key? key, required String dateId})
      : _dateId = dateId,
        super(key: key) {
    print('dateId: $dateId');
  }

  @override
  _IncomesWidgetState createState() => _IncomesWidgetState();
}

class _IncomesWidgetState extends State<IncomesWidget> {
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
        title: Text('Приходы'),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Добавить приход',
        onPressed: () {
          _createAndEditIncome();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(context) {
    return StreamBuilder<Object?>(
      stream: supabase
          .from('incomes')
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
                child: Text('Что-то пошло не так'),
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
            CardWidget(cardModel: _cardModel, title: 'Общий приход'),
            Divider(),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final income = items[index];
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: Key(income['id'].toString()),
                    child: Card(
                      child: ListTile(
                        contentPadding: Utils.getEdgeInsetsForCard(),
                        title: _getTitle(income['name'], income['price'] ?? 0.0),
                        onTap: () {
                          _createAndEditIncome(income);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                if (await Utils.alertDialogDelete(context, income['name'])) {
                                  await _delete(income['id']);
                                  //setState(() {}); // Обновление UI после удаления
                                }
                              },
                            ),
                            IconButton(
                              padding: Utils.getPaddingIconButton(),
                              onPressed: () {
                                _createAndEditIncome(income);
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ),
                    ),
                    confirmDismiss: (DismissDirection direction) async {
                      return await Utils.alertDialogDelete(context, income['name']);
                    },
                    onDismissed: (direction) async {
                      await _delete(income['id']);
                      //setState(() {}); // Обновление UI после удаления
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

  void _setPrice(double price) {
    _cardModel.add(price);
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

  Future<void> _createAndEditIncome([Map<String, dynamic>? income]) async {
    bool isEdit = income != null;
    String id = income?['id'] ?? '';
    String dateCreate = income?['dateCreate'] ?? DateTime.now().toIso8601String();

    if (isEdit) {
      _nameController.text = income!['name'] ?? '';
      _priceController.text = (income['price'] ?? 0).toString();
      _commentController.text = income['comment'] ?? '';
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
                          await supabase.from('incomes').update({
                            'name': name,
                            'price': price,
                            'comment': comment,
                          }).eq('id', id);
                        } else {
                          await supabase.from('incomes').insert({
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
                        //setState(() {}); // Обновление UI после создания или редактирования
                      } catch (e) {
                        print('Ошибка при сохранении прихода: $e');
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
      await supabase.from('incomes').delete().eq('id', id);
    } catch (e) {
      print('Ошибка при удалении: $e');
    }
  }
}