import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:skribbl/models/my_custum_painter.dart';
import 'package:skribbl/models/touch_points.dart';
import 'package:skribbl/screens/final_lead_board_screen.dart';
import 'package:skribbl/screens/home_screen.dart';
import 'package:skribbl/screens/waiting_lobby_screen.dart';
import 'package:skribbl/widgets/player_scoreboard_drawer.dart';
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
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int guessedUsedCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputreadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderboard = false;

  @override
  void initState() {
    super.initState();
    connect();
    print(widget.data);
    print(widget.screenFrom);
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataofRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(
        const Text(
          "_",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void connect() {
    _socket = IO.io(
      'https://inksync-backend.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // WebSocket fallback
          .disableAutoConnect() // manually connect
          .build(),
    );

    _socket.connect();

    if (widget.screenFrom == "createRoom") {
      _socket.emit("create-game", widget.data);
    } else {
      _socket.emit("join-game", widget.data);
    }
    _socket.onConnectError((err) => print("❌ Connect Error: $err"));
    _socket.onError((err) => print("❌ General Error: $err"));
    _socket.onDisconnect((_) => print("🔌 Disconnected from server"));

    _socket.onConnect((_) {
      print("🟢 Connected to socket server!");
      _socket.on("updateRoom", (roomData) {
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataofRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString(),
            });
          });
        }
      });

      _socket.on(
        'notCorrectGame',
        (data) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        ),
      );

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

      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUsedCtr = msgData['guessedUserCtr'];
        });
        if (guessedUsedCtr == dataofRoom['players'].length - 1) {
          _socket.emit('change-turn', dataofRoom['name']);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataofRoom['word'];
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 3), () {
              setState(() {
                dataofRoom = data;
                renderTextBlank(data['word']);
                isTextInputreadOnly = false;
                guessedUsedCtr = 0;
                _start = 60;
                points.clear();
              });
              Navigator.of(context).pop();
              _timer.cancel();
              startTimer();
            });
            return AlertDialog(title: Center(child: Text("Word was $oldWord")));
          },
        );
      });

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString(),
            });
          });
        }
      });

      _socket.on("show-leaderboard", (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString(),
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
        setState(() {
          _timer.cancel();
          isShowFinalLeaderboard = true;
        });
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString);
        Color otherColor = Color(value);
        setState(() {
          selecedColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clean-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextInputreadOnly = true;
        });
      });

      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString(),
            });
          });
        }
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
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
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
        drawer: PlayerScoreboardDrawer(scoreboard),
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body:
            dataofRoom != null
                ? dataofRoom['isJoin'] != true
                    ? !isShowFinalLeaderboard
                        ? Stack(
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
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                        child: RepaintBoundary(
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustumPainter(
                                              pointsList: points,
                                            ),
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
                                      icon: Icon(
                                        Icons.color_lens,
                                        color: selecedColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        min: 1.0,
                                        max: 10,
                                        label: "Storewidth : $strokeWidth",
                                        activeColor: selecedColor,
                                        value: strokeWidth,
                                        onChanged: (double value) {
                                          Map map = {
                                            'value': value,
                                            'roomName': dataofRoom['name'],
                                          };
                                          _socket.emit('stroke-width', map);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _socket.emit(
                                          'clean-screen',
                                          dataofRoom['name'],
                                        );
                                      },
                                      icon: Icon(
                                        Icons.layers_clear,
                                        color: selecedColor,
                                      ),
                                    ),
                                  ],
                                ),
                                dataofRoom['turn']['nickname'] !=
                                        widget.data['nickname']
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: textBlankWidget,
                                    )
                                    : Container(
                                      child: Text(
                                        dataofRoom['word'],
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),

                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      var msg = messages[index].values;
                                      return ListTile(
                                        title: Text(
                                          msg.elementAt(0),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          msg.elementAt(1),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            dataofRoom['turn']['nickname'] !=
                                    widget.data['nickname']
                                ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: TextField(
                                      readOnly: isTextInputreadOnly,
                                      autocorrect: false,
                                      controller: controller,
                                      onSubmitted: (value) {
                                        print(value.trim());
                                        if (value.trim().isNotEmpty) {
                                          Map map = {
                                            'username': widget.data['nickname'],
                                            'msg': value.trim(),
                                            'word': dataofRoom['word'],
                                            'roomName': widget.data['name'],
                                            'guessedUserCtr': guessedUsedCtr,
                                            'totalTime': 60,
                                            'timeTaken': 60 - _start,
                                          };
                                          _socket.emit('msg', map);
                                          controller.clear();
                                        }
                                      },
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        filled: true,
                                        fillColor: Color(0xffF5F5FA),
                                        hintText: "Your Guess",
                                        hintStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                : Container(),
                            SafeArea(
                              child: IconButton(
                                icon: Icon(Icons.menu, color: Colors.black),
                                onPressed:
                                    () =>
                                        scaffoldKey.currentState!.openDrawer(),
                              ),
                            ),
                          ],
                        )
                        : FinalLeadBoardScreen(scoreboard, winner)
                    : WaitingLobbyScreen(
                      lobbyName: dataofRoom['name'],
                      noOfPlayers: dataofRoom['players'].length,
                      occupancy: dataofRoom['occupancy'],
                      players: dataofRoom['players'],
                    )
                : Center(child: CircularProgressIndicator()),
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 30),
          child: FloatingActionButton(
            onPressed: () {},
            elevation: 7,
            backgroundColor: Colors.white,
            child: Text(
              '$_start',
              style: TextStyle(color: Colors.black, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }
}
