import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/utils.dart';
import '../models/supabase_service.dart';

class UseCheckedWidget extends StatefulWidget {
  final String _userId;
  int _useChecked;

  UseCheckedWidget({
    Key? key,
    required String userId,
    required int useChecked,
  })  : _userId = userId,
        _useChecked = useChecked,
        super(key: key);

  @override
  _UseCheckedWidgetState createState() => _UseCheckedWidgetState();
}

class _UseCheckedWidgetState extends State<UseCheckedWidget> {
  final supabase = SupabaseService().supabase;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _useChecked();
        setState(() {}); // Обновление UI после изменения
      },
      icon: Icon(
        Icons.check_sharp,
        color: widget._useChecked == 1 ? Colors.teal : Colors.black,
      ),
    );
  }

  Future<void> _useChecked() async {
    if (await Utils.alertDialogAll(
        context, 'Все проверено', "'Установить, что 'Все проверено''")) {
      try {
        await supabase
            .from('users')
            .update({'checked': 1})
            .eq('id', widget._userId);
        widget._useChecked = 1; // Обновляем локальное состояние
      } catch (e) {
        print('Ошибка при обновлении checked: $e');
      }
    }
  }
}