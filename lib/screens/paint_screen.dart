import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  StrokeCap strokeType = StrokeCap.round;
  Color selecedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
    print(widget.screenFrom);
  }

  @override
  void dispose() {
    _socket.dispose(); // Disconnects and destroys the socket
    print("🔴 Disconnected socket on dispose");
    super.dispose();
  }

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
      });

      _socket.on('points', (point) {
        if (point['details'] != null && point['paint'] != null) {
          final paintData = point['paint'];
          setState(() {
            points.add(
              TouchPoints(
                points: Offset(
                  (point['details']['dx']).toDouble(),
                  (point['details']['dy']).toDouble(),
                ),
                paint:
                    Paint()
                      ..strokeCap = strokeType
                      ..isAntiAlias = true
                      ..color = Color(
                        int.parse(paintData['color'], radix: 16),
                      ).withOpacity(opacity)
                      ..strokeWidth = paintData['strokeWidth'].toDouble(),
              ),
            );
          });
        }
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString);
        Color otherColor = Color(value);
        setState(() {
          selecedColor = otherColor;
        });
      });
    });

    _socket.onConnectError((err) {
      print("❌ Connect Error: $err");
    });

    _socket.onError((err) {
      print("❌ General Error: $err");
    });

    _socket.onDisconnect((_) {
      print("🎈 Disconnected from server");
    });
  }

  void emitPaint(Offset? offset) {
    _socket.emit('paint', {
      'details': offset == null ? null : {'dx': offset.dx, 'dy': offset.dy},
      'roomName': widget.data['name'],
      'paint': {
        'color': selecedColor.value.toRadixString(16),
        'strokeWidth': strokeWidth,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Choose Color"),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selecedColor,
                  onColorChanged: (color) {
                    setState(() {
                      selecedColor = color;
                    });

                    // Convert color to hex string safely
                    String valueString = color.value
                        .toRadixString(16)
                        .padLeft(8, '0');

                    print("Selected color: $valueString");

                    Map map = {
                      'color': valueString,
                      'roomName': dataofRoom['name'],
                    };

                    _socket.emit('color-change', map);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            ),
      );
    }

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
                  height: height * 0.55,
                  width: width,
                  child: GestureDetector(
                    onPanStart: (details) {
                      emitPaint(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      emitPaint(details.localPosition);
                    },
                    onPanEnd: (details) {
                      emitPaint(null);
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        selectColor();
                      },
                      icon: Icon(Icons.color_lens, color: selecedColor),
                    ),
                    Expanded(
                      child: Slider(
                        min: 1.0,
                        max: 10,
                        label: "Storewidth : $strokeWidth",
                        activeColor: selecedColor,
                        value: strokeWidth,
                        onChanged: (double value) {},
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.layers_clear, color: selecedColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
