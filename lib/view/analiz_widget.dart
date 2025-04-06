import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnalizWidget  extends StatefulWidget {

  @override
  _AnalizWidgetState createState() => _AnalizWidgetState();
}

class _AnalizWidgetState extends State<AnalizWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Анализ продаж'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context)
  {
    return Container();
  }

}