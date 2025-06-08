import 'package:flutter/material.dart';
import 'package:skribbl/utils/utlis.dart';
import 'package:skribbl/widgets/custum_text_feilds.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController name_of_person_controller =
      TextEditingController();
  final TextEditingController name_of_room_controller = TextEditingController();
  late String? _maxRoundsValue;
  late String? _roomSizeValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text("Create Room", style: textStyleHome)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            CustumTextFeilds(
              controller: name_of_person_controller,
              hintText: "Enter You Name",
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            CustumTextFeilds(
              controller: name_of_room_controller,
              hintText: "Enter You Room Name",
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    focusColor: Color(0xffF5F6FA),
                    items:
                        <String>["2", "5", "10", "15"]
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                            .toList(),
                    hint: const Text(
                      'Select Max Rounds',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _maxRoundsValue = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                Expanded(
                  child: DropdownButton<String>(
                    focusColor: Color(0xffF5F6FA),
                    items:
                        <String>["2", "3", "4", "5", "6", "7", "8"]
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                            .toList(),
                    hint: const Text(
                      'Select Room Size',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _roomSizeValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Create",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(color: Colors.white),
                  ),
                  minimumSize: MaterialStateProperty.all(
                    Size(MediaQuery.of(context).size.width / 2.5, 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
