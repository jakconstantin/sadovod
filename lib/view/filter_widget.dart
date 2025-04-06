import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/order_prms.dart';
import 'checkbox_widget.dart';

class FilterWidget extends StatefulWidget {


  late OrderPrms _orderFilterPrms;

  FilterWidget(
      OrderPrms prms,
      {Key? key,}) :super(key: key) {

    _orderFilterPrms = prms;
  }

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

//orders
class _FilterWidgetState extends State<FilterWidget> {
  @override
  Widget build(BuildContext context) {
     return Padding(
      padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: (){
                      widget._orderFilterPrms.clearPrms();
                      setState(() {
                      });
                    },
                    child: Text('Сбросить всё'),),
                ],
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Фильтры', overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),


              IconButton(
                splashRadius: 24.0,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close,),),
            ],
          ),

          _paidWidget(),
          _bookedWidget(),
          _inFactWidget(),
          _wroteToSeller(),
          _nothingWasFilledWidget(),
          _packedWidget(),

          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child:Text('Применить'),
                onPressed: () async {


                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _paidWidget() {
    return CheckboxWidget(title: 'Оплачено', value: widget._orderFilterPrms.isPaid,
      onSelect: (value){
        print('paidWidget set: $value');
        widget._orderFilterPrms.isPaid = value;
      }, );
  }

  Widget _bookedWidget() {
    return CheckboxWidget(title: 'Бронь', value: widget._orderFilterPrms.isBooked,
      onSelect: (value) {
        print('bookedWidget set: $value');
        widget._orderFilterPrms.isBooked = value;
      },);
  }

  Widget _inFactWidget() {
    return CheckboxWidget(title: 'Оплачено, по факту', value: widget._orderFilterPrms.isInFact,
      onSelect: (value) {
        print('inFactWidget set: $value');
        widget._orderFilterPrms.isInFact = value;
      },);
  }

  //wrote to  seller
  Widget _wroteToSeller()
  {
    return CheckboxWidget(title: 'Продавцу написали', value: widget._orderFilterPrms.isWroteToSeller,
      onSelect: (value) {
        widget._orderFilterPrms.isWroteToSeller = value;
      },);
  }

  //nothing was filled
  Widget _nothingWasFilledWidget()
  {
    return CheckboxWidget(title: 'Ничего не заполнено', value: widget._orderFilterPrms.isNothingWasFille,
      onSelect: (value) {
        widget._orderFilterPrms.isNothingWasFille = value;
      },);
  }

  Widget _packedWidget()
  {
    return CheckboxWidget(title: 'Не упаковано', value: widget._orderFilterPrms.isPacked,
      onSelect: (value) {
        widget._orderFilterPrms.isPacked = value;
      },);
  }

}