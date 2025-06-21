import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skribbl/routes/routes.dart';
import 'package:skribbl/routes/routes_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: RoutesName.homeScreem,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
