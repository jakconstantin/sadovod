import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/utils.dart';
import 'package:sadovod/view/search_widget.dart';
import '../models/supabase_service.dart';
import 'analiz_widget.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final supabase = SupabaseService().supabase;
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Business', style: optionStyle),
    Text('Index 2: School', style: optionStyle),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildDrawer(context);
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            title: const Text('Анализ продаж'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnalizWidget()),
              );
            },
          ),
          ListTile(
            title: const Text('Сохранить данные'),
            onTap: () async {
              if (await Utils.alertDialogSave(context, '')) {
                await _saveDatabase();
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveDatabase() async {
    try {
      final response = await supabase.from('date_purchases').select();
      final data = response as List<dynamic>;
      print('Данные из таблицы date_purchases: $data');
    } catch (e) {
      print('Ошибка при сохранении данных: $e');
    }
  }
}