import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skribbl/routes/routes_name.dart';
import 'package:skribbl/utils/utlis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFEFE),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/homescreen.json',
            controller: _controller,
            onLoaded: (comp) {
              _controller
                ..duration =
                    comp.duration ~/
                    4 // 2x speed
                ..repeat();
            },
          ),

          const Text("Create/Join a room to play!", style: textStyleHome),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.createRoomScreen);
                },

                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    BorderSide(color: Colors.blue, width: 1),
                  ),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(color: Colors.white),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 2.5, 50),
                  ),
                ),
                child: const Text(
                  "Create",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RoutesName.joinRoomScreen);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(color: Colors.white),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 2.5, 50),
                  ),
                ),
                child: const Text(
                  "Join",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
