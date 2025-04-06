import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_prms.dart';
import '../models/supabase_service.dart';
import 'checkbox_widget.dart';

class OrderWidget extends StatefulWidget {
  final TextEditingController _nameOrderController;
  final TextEditingController _priceOrderController;
  final TextEditingController _countOrderController;
  final TextEditingController _urlOrderController;
  final TextEditingController _descriptionOrderController;
  final TextEditingController _commentOrderController;
  final bool _isEdit;
  final String _path;
  final String _dateId;
  final String _userId;
  final OrderPrms _prms;

  OrderWidget(
      this._nameOrderController,
      this._priceOrderController,
      this._countOrderController,
      this._urlOrderController,
      this._descriptionOrderController,
      this._commentOrderController,
      this._isEdit,
      this._path,
      this._dateId,
      this._userId,
      this._prms, {
        Key? key,
      }) : super(key: key);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  final supabase = SupabaseService().supabase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget._prms.userName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                splashRadius: 24.0,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: widget._nameOrderController,
                    decoration: const InputDecoration(labelText: 'Наименование'),
                  ),
                  TextField(
                    controller: widget._descriptionOrderController,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: widget._priceOrderController,
                    decoration: const InputDecoration(labelText: 'Цена'),
                  ),
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    controller: widget._countOrderController,
                    decoration: const InputDecoration(labelText: 'Количество'),
                  ),
                  _urlWidget(),
                  _paidWidget(),
                  _bookedWidget(),
                  _inFactWidget(),
                  _wroteToSeller(),
                  _packedWidget(),
                  TextField(
                    controller: widget._commentOrderController,
                    decoration: const InputDecoration(labelText: 'Комментарий'),
                  ),
                  const SizedBox(height: 5),
                  _dateCreateWidget(),
                  _authUserEmailWidget(),
                  const SizedBox(height: 20),
                  _buttonWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _urlWidget() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget._urlOrderController,
                decoration: const InputDecoration(labelText: 'Url'),
              ),
            ),
            IconButton(
              onPressed: () {
                if (widget._urlOrderController.text.trim().isNotEmpty) {
                  FlutterClipboard.copy(widget._urlOrderController.text)
                      .then((value) => print('copied text'));
                }
              },
              icon: Icon(Icons.copy),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          child: const Text('Открыть'),
          onPressed: () async {
            if (widget._urlOrderController.text.isNotEmpty) {
              _launchInBrowser(Uri.parse(widget._urlOrderController.text));
            }
          },
        ),
      ],
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    print('Url: $url');
    if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  Widget _paidWidget() {
    return CheckboxWidget(
      title: 'Оплачено',
      value: widget._prms.isPaid,
      onSelect: (value) {
        print('paidWidget set: $value');
        setState(() {
          widget._prms.isPaid = value;
        });
      },
    );
  }

  Widget _bookedWidget() {
    return CheckboxWidget(
      title: 'Бронь',
      value: widget._prms.isBooked,
      onSelect: (value) {
        print('bookedWidget set: $value');
        setState(() {
          widget._prms.isBooked = value;
        });
      },
    );
  }

  Widget _inFactWidget() {
    return CheckboxWidget(
      title: 'Оплачено, по факту',
      value: widget._prms.isInFact,
      onSelect: (value) {
        print('inFactWidget set: $value');
        setState(() {
          widget._prms.isInFact = value;
        });
      },
    );
  }

  Widget _wroteToSeller() {
    return CheckboxWidget(
      title: 'Продавцу написали',
      value: widget._prms.isWroteToSeller,
      onSelect: (value) {
        setState(() {
          widget._prms.isWroteToSeller = value;
        });
      },
    );
  }

  Widget _packedWidget() {
    return CheckboxWidget(
      title: 'Упаковано',
      value: widget._prms.isPacked,
      onSelect: (value) {
        print('_packedWidget: $value');
        setState(() {
          widget._prms.isPacked = value;
        });
      },
    );
  }

  Widget _dateCreateWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Дата создания: ${widget._prms.dateCreate}',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _authUserEmailWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Создатель: ${widget._prms.authUserEmail}',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buttonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          child: widget._isEdit ? Text('Обновить') : Text('Создать'),
          onPressed: () async {
            final String name = widget._nameOrderController.text;
            double? price = double.tryParse(widget._priceOrderController.text) ?? 0;
            int? count = int.tryParse(widget._countOrderController.text) ?? 1;
            final String url = widget._urlOrderController.text;

            try {
              if (widget._isEdit) {
                await supabase.from('orders').update({
                  'name': name,
                  'dateId': widget._dateId,
                  'userId': widget._userId,
                  'price': price,
                  'count': count,
                  'url': url,
                  'paid': widget._prms.isPaid,
                  'booked': widget._prms.isBooked,
                  'inFact': widget._prms.isInFact,
                  'wroteToSeller': widget._prms.isWroteToSeller,
                  'packed': widget._prms.isPacked,
                  'comment': widget._commentOrderController.text,
                  'description': widget._descriptionOrderController.text,
                }).eq('id', widget._path);
              } else {
                await supabase.from('orders').insert({
                  'name': name,
                  'dateId': widget._dateId,
                  'userId': widget._userId,
                  'price': price,
                  'count': count,
                  'url': url,
                  'paid': widget._prms.isPaid,
                  'booked': widget._prms.isBooked,
                  'inFact': widget._prms.isInFact,
                  'wroteToSeller': widget._prms.isWroteToSeller,
                  'packed': widget._prms.isPacked,
                  'comment': widget._commentOrderController.text,
                  'description': widget._descriptionOrderController.text,
                  'dateCreate': widget._prms.dateCreate,
                  'authUserEmail': widget._prms.authUserEmail,
                });
              }
              Navigator.of(context).pop(true); // Возвращаем true для обновления UI в вызывающем виджете
            } catch (e) {
              print('Ошибка при сохранении заказа: $e');
            }
          },
        ),
      ],
    );
  }
}