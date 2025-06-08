import 'package:flutter/material.dart';
import 'package:skribbl/routes/routes_name.dart';
import 'package:skribbl/screens/create_room_screen.dart';
import 'package:skribbl/screens/home_screen.dart';
import 'package:skribbl/screens/join_room_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeScreem:
        return MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        );

      case RoutesName.createRoomScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => const CreateRoomScreen(),
        );

      case RoutesName.joinRoomScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => const JoinRoomScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) {
            return const Scaffold(
              body: Center(child: Text('No route defined')),
            );
          },
        );
    }
  }
}
