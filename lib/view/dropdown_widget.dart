import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {

  late void Function(int value) _onSelect;
  late int _value;
  DropdownWidget({Key? key, required int value, required void Function(int percent) onSelect }):super(key: key) {
    _value = value;
    _onSelect = onSelect;
  }

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {

  static const List<int> list = <int>[16, 8];
  int dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
   return DropdownButton<int>(
     value: widget._value,
     icon: const Icon(Icons.arrow_downward),
     elevation: 16,
     //style: const TextStyle(color: Colors.deepPurple),
     underline: Container(
       height: 2,
       color: Colors.deepPurpleAccent,
     ),
     onChanged: (int? value) {
       widget._value = value!;
       widget._onSelect(value);
       setState(() {
       });
       // This is called when the user selects an item.
       // setState(() {
       //   dropdownValue = value!;
       // });
     },
     items: list.map<DropdownMenuItem<int>>((int value) {
       return DropdownMenuItem<int>(
         value: value,
         child: Text(value.toString()),
       );
     }).toList(),);
  }
}
