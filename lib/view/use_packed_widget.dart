import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/utils.dart';
import '../models/supabase_service.dart';

class UsePackedWidget extends StatefulWidget {
  final String _orderId;
  int _usePacked;
  final Function(int) _onPackedChanged;

  UsePackedWidget({
    Key? key,
    required String orderId,
    required int usePacked,
    required Function(int) onPackedChanged,
  })  : _orderId = orderId,
        _usePacked = usePacked,
        _onPackedChanged = onPackedChanged,
        super(key: key);

  @override
  _UsePackedWidgetState createState() => _UsePackedWidgetState();
}

class _UsePackedWidgetState extends State<UsePackedWidget> {
  final supabase = SupabaseService().supabase;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _usePacked();
        setState(() {}); // Обновление UI после изменения
      },
      icon: widget._usePacked == 1
          ? Icon(Icons.done_all, color: Colors.red)
          : Icon(Icons.done),
    );
  }

  Future<void> _usePacked() async {
    if (await Utils.alertDialogAll(
        context, 'Упаковано', "'Установить, что 'Упаковано''")) {
      try {
        await supabase
            .from('orders')
            .update({'packed': 1})
            .eq('id', widget._orderId);
        widget._usePacked = 1; // Обновляем локальное состояние
        widget._onPackedChanged(1); // Уведомляем родительский виджет
        print('order id: ${widget._orderId} updated to packed = 1');
      } catch (e) {
        print('Ошибка при обновлении packed: $e');
      }
    }
  }
}