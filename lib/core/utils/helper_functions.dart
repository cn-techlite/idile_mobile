// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';

import 'package:idile_mobile_app/app/router/routers.dart';

void navigateToRoute(BuildContext context, dynamic routeClass) {
  Navigator.push(context, CupertinoPageRoute(builder: (context) => routeClass));
}

void navigateAndReplaceRoute(BuildContext context, dynamic routeClass) {
  Navigator.pushReplacement(
    context,
    CupertinoPageRoute(builder: (context) => routeClass),
  );
}

void navigateAndRemoveUntilRoute(BuildContext context, dynamic routeClass) {
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute(builder: (context) => routeClass),
    (route) => false,
  );
}

void navPush(BuildContext context, String route) {
  Navigator.push(context, generateRoute(RouteSettings(name: route)));
}
