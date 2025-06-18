import 'package:flutter/material.dart';
import 'package:skribbl/models/my_custum_painter.dart';
import 'package:skribbl/models/touch_points.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map data;
  final String screenFrom;
  PaintScreen({required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataofRoom = {};
  List<TouchPoints> points = [];

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
    print(widget.screenFrom);
  }

  // Remener version -> flutter -> 1.0.2 , nodejs -> 2.3.0 , port -> 3000

  void connect() {
    _socket = IO.io('http://192.168.1.2:3000', <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    _socket.connect();

    if (widget.screenFrom == "createRoom") {
      _socket.emit("create-game", widget.data);
    } else {
      _socket.emit("join-game", widget.data);
    }

    _socket.onConnect((_) {
      print("🟢 Connected to socket server!");
      _socket.on("updateRoom", (roomData) {
        setState(() {
          dataofRoom = roomData;
        });
        if (roomData['isJoin'] != true) {}
      });
    });

    _socket.onConnectError((err) {
      print("❌ Connect Error: $err");
    });
    _socket.onError((err) {
      print("❌ General Error: $err");
    });

    _socket.onDisconnect((_) {
      print("🎈 Disconneted to server");
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: height*0.55,
                  width: width,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      print(details.localPosition.dx);
                      _socket.emit('paint', {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name'],
                      });
                    },
                    onPanStart: (details) {
                      print(details.localPosition.dx);
                      _socket.emit('paint', {
                        'details': {
                          'dx': details.localPosition.dx,
                          'dy': details.localPosition.dy,
                        },
                        'roomName': widget.data['name'],
                      });
                    },
                    onPanEnd: (details) {
                      _socket.emit('paint', {
                        'details': null,
                        'roomName': widget.data['name'],
                      });
                    },
                    child: SizedBox.expand(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: MyCustumPainter(pointsList: points),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
