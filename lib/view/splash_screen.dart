import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sadovod/View/home_page.dart';

import '../constants/app_assets.dart';
import '../models/supabase_service.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {

  SplashScreen({Key? key}):super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}
final GlobalKey<NavigatorState> kNavigatorKey = GlobalKey<NavigatorState>();

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initKeys();
  }

  void _initKeys()async {
    // Timer(Duration(seconds: 2),
    //         () =>
    //         Navigator.push(context,
    //             MaterialPageRoute(
    //                 builder: (context) =>
    //                     HomePage()
    //             ))
    // );

    Timer(Duration(seconds: 2),
            () =>
        {
          SupabaseService().onListenUser((user) {
            if (user == null) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AuthScreen()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HomePage()));
            }
          })
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child:
        Center(
          child: Image.asset(AppAssets.images.logo),
        ),
      ),
    );
  }



}