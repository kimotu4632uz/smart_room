import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:smart_room/bloc/light_bloc.dart';
import 'package:smart_room/bloc/aircon_bloc.dart';
import 'package:smart_room/utils.dart';

class RoomState {
  int temp;
  int humid;

  RoomState({required this.temp, required this.humid});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<RoomState> getRoomStateStream() async* {
    while(true) {
      final sp = await SharedPreferences.getInstance();
      final url = sp.getString("room_get_url");
      if (url != null) {
        final resp = await http.get(Uri.parse(url));
        final respj = json.decode(resp.body);
        if (respj["status"] == "OK") {
          final result = RoomState(
              temp: int.parse(respj["temp"].split('.')[0]),
              humid: int.parse(respj["humid"].split('.')[0]));
          print(result.temp);
          yield result;
        }
      }
      await Future.delayed(Duration(minutes: 5));
    }
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: NeumorphicAppBar(
        actions: [
          NeumorphicButton(
            child: Center(
              child: NeumorphicIcon(Icons.settings, style: NeumorphicStyle(color: Colors.black),),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          )
        ],
        title: NeumorphicText(
          "My room",
          style: NeumorphicStyle(color: Colors.black87),
          textStyle: NeumorphicTextStyle(fontSize: 20),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: getRoomStateStream(),
            initialData: RoomState(temp: 0, humid: 0),
            builder: (_, AsyncSnapshot<RoomState> snapshot) =>
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                NeumorphicIcon(
                  Icons.thermostat,
                  style: NeumorphicStyle(
                    color: Colors.black87,
                  ),
                  size: 35,
                ),
                NeumorphicText(
                    (snapshot.data?.temp.toString() ?? "") + "℃",
                  style: NeumorphicStyle(
                    color: Colors.black87,
                  ),
                  textStyle: NeumorphicTextStyle(
                    fontSize: 35,
                  ),
                ),
                SizedBox(
                  height: 35,
                  width: 30,
                ),
                NeumorphicIcon(
                  Icons.water,
                  style: NeumorphicStyle(
                    color: Colors.black87
                  ),
                  size: 35,
                ),
                NeumorphicText(
                  (snapshot.data?.humid.toString() ?? "") + "%",
                  style: NeumorphicStyle(
                    color: Colors.black87,
                  ),
                  textStyle: NeumorphicTextStyle(
                      fontSize: 35
                  ),
                ),
                SizedBox(
                  height: 35,
                  width: 20,
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlPanel(
                powerStream: (context) => Provider.of<LightBloc>(context).getStream(LightBlocVars.Power),
                dataStream: (context) => Provider.of<LightBloc>(context)
                  .getStream(LightBlocVars.Level)
                  .transform(StreamTransformer.fromHandlers(
                    handleData: (value, sink) {
                      sink.add(value + "%");
                    }
                  )),
                onUpdate: (context, value) => Provider.of<LightBloc>(context, listen: false).update(LightBlocVars.Power, value.toString()),
                icon: Icons.lightbulb_outline_rounded,
                label: "照明",
                navigate: "/light",
              ),
             ControlPanel(
               powerStream: (context) => Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Power),
               dataStream: (context) => Provider.of<AirconBloc>(context)
                 .getStream(AirconBlocVars.Temp)
                 .transform(StreamTransformer.fromHandlers(
                   handleData: (value, sink) {
                     sink.add(value + "℃");
                   }
                 )),
               onUpdate: (context, value) => Provider.of<AirconBloc>(context, listen: false).update(AirconBlocVars.Power, value.toString()),
               icon: Icons.air_rounded,
               label: "エアコン",
               navigate: "/aircon",
             ),
           ],
          )
        ],
      ),
    );
}

class ControlPanel extends StatelessWidget {
  final Stream<String> Function(BuildContext context) powerStream, dataStream;
  final void Function(BuildContext context, bool value) onUpdate;
  final IconData icon;
  final String label;
  final String navigate;

  ControlPanel({required this.powerStream, required this.dataStream, required this.onUpdate, required this.icon, required this.label, required this.navigate});

  @override
  Widget build(BuildContext context) => Expanded(
    child: AspectRatio(
      aspectRatio: 1.0,
      child: StreamBuilder(
        stream: powerStream(context),
        initialData: "false",
        builder: (context, snapshot) =>
          NeumorphicButton(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeumorphicIcon(
                        this.icon,
                        size: 40,
                        style: NeumorphicStyle(
                            color: Colors.black87
                        ),
                      ),
                      StreamBuilder(
                        stream: dataStream(context),
                        builder: (context, snapshot) => NeumorphicText(
                          snapshot.data.toString(),
                          style: NeumorphicStyle(
                            color: Colors.black87
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeumorphicText(this.label,
                        style: NeumorphicStyle(color: Colors.black87),
                        textStyle: NeumorphicTextStyle(fontSize: 15),),
                      NeumorphicSwitch(
                        style: NeumorphicSwitchStyle(
                          activeTrackColor: Colors.blueAccent,
                          thumbDepth: 10,
                          trackDepth: 0,
                        ),
                        height: 30,
                        value: snapshot.data.toString().parseBool(),
                        onChanged: (value) => onUpdate(context, value),
                      )
                    ],
                  ),
                ]
            ),
            onPressed: () {
              Navigator.pushNamed(context, navigate);
            },
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12)),
              shape: NeumorphicShape.flat,
              lightSource: LightSource.topLeft,
              depth: snapshot.data.toString().parseBool() ? -3 : 6,
              color: snapshot.data.toString().parseBool() ? Colors.blueAccent : NeumorphicTheme.currentTheme(context).baseColor,
            ),
          ),
        ),
    ),
  );
}