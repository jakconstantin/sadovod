import 'dart:js';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils
{
  static Future<bool> alertDialogDelete(BuildContext context, String text) async
  {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Нет"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Да"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Удалить"),
      content: Text("Удалить '$text'?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result;
  }

  static Future<bool> alertDialogAll(BuildContext context, String title, String content) async
  {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Нет"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Да"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text("$content?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result;
  }

  static Future<bool> alertDialogSave(BuildContext context, String text) async
  {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Нет"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Да"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true)
            .pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Сохранить"),
      content: Text("Сохранить данные?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    bool result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result;
  }


  static Color getColorStatus(dynamic paid, dynamic booked, dynamic inFact, dynamic wroteToSeller) {
    Color c = Colors.white;

    if(wroteToSeller == 1) {
      c = Colors.black12;
    }

    if (paid == 1) {
      c = Colors.blue;
    }

    if (booked == 1) {
      c = Colors.teal;
      //c = const Color(0xFF30d5c8 );
    }

    if (inFact == 1) {
      c = Colors.yellow;
    }

    return c;
  }


  static EdgeInsetsGeometry getEdgeInsetsForCard()
  {
    return EdgeInsets.fromLTRB(10, 0, 0, 0);
  }

  static EdgeInsetsGeometry getPaddingIconButton() {
    return EdgeInsets.fromLTRB(0, 0, 0, 0);
  }

  static Widget getTitle(String userName, String name,  double price, int count,
                         int userPercent, bool useComment, String authUserEmail,
                         Function()? onUserPressed, int index)
  {
    double priceAll = price * count;
    double priceResult = priceAll + (priceAll * userPercent)/100;
    priceResult = Utils.roundDouble(priceResult, 2);

    return Row(
      children: [
        Text((index+1).toString()+" ", style: TextStyle(color: Colors.black54)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              userName.isEmpty?
              Container():
              TextButton(
                onPressed: () {
                  if (onUserPressed != null) {
                    onUserPressed();
                  }
                },
                child:Text(userName, overflow: TextOverflow.ellipsis, style: TextStyle( fontWeight: FontWeight.bold),),
              ),


              Text(name, overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),
        getFirstLetterEmail(authUserEmail),
        getIconComment(useComment),
        const SizedBox(
          width: 3,
        ),
        Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: [
            Text('$price', style: TextStyle( fontWeight: FontWeight.normal, fontSize: 12, ),),
            Text('Кол: $count', style: TextStyle( fontWeight: FontWeight.normal, fontSize: 12,),),
            Text('$priceResult', style: TextStyle( fontWeight: FontWeight.bold),),
          ],          
        ),
      ],
    );
  }

  static Icon getIconComment(bool useComment)
  {
    return  useComment?Icon(CupertinoIcons.chat_bubble_text, color: Colors.purpleAccent,): Icon(CupertinoIcons.chat_bubble);
  }

  static Widget getFirstLetterEmail(String authUserEmail) {
    String firstLetter = '';
    if (authUserEmail.isNotEmpty) {
      firstLetter = authUserEmail.substring(0, 1);
    }
    return Text(firstLetter);
  }

  static double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

}