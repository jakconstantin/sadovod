import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {

  // late void Function(int value) _onSelect;
  // late int _value;
  // CheckboxWidget({Key? key, required int value, required void Function(int percent) onSelect }):super(key: key) {
  //   _value = value;
  //   _onSelect = onSelect;
  // }

  late String _title ="";
  late int _value;
  late void Function(int value) _onSelect;
  CheckboxWidget({Key? key,
    required  String title,
    required int value,
    required void Function(int value) onSelect
  }):super(key: key) {
    _title = title;
    _onSelect = onSelect;
    _value = value;
  }

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {


  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget._title),
      value: widget._value == 0 ? false : true,
      onChanged: (bool? value) {
        widget._value = value! ? 1 : 0;
        widget._onSelect(widget._value);
        setState(() {
        });

      },);
  }
}