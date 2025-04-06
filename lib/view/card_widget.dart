import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/card_model.dart';

class CardWidget extends StatefulWidget {

  late CardModel _cardModel;
  late String _title;
  CardWidget({Key? key,
    required String title,
    required CardModel cardModel }):super(key: key) {
    _cardModel = cardModel;
    _title = title;
  }

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {


  @override
  void initState() {
    super.initState();
    widget._cardModel.addListener(() {
      print('cardModel addListener price: ${widget._cardModel.totalPrice}');
      Timer(new Duration(seconds: 1), () {
      });
    });
  }


  @override
  Widget build(BuildContext context) {
   print('run build');
   return  Card(
     child: ListTile(
       //contentPadding: Utils.getEdgeInsetsForCard(),
       title: _getTitle(widget._title, widget._cardModel.totalPrice),
     ),
   );
  }

  Widget _getTitle(String name, double price)
  {
    return Row(
      children: [
        Expanded(
          child: Text(name, overflow: TextOverflow.ellipsis,),
        ),
        Text(price.toString()),
      ],
    );
  }

}
