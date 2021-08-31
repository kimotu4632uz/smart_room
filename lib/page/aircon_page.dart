import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:smart_room/bloc/aircon_bloc.dart';
import 'package:smart_room/utils.dart';
import 'package:smart_room/widget/progress_bar.dart';
import 'package:smart_room/widget/dialog_button.dart';
import 'package:smart_room/wind_v_icon.dart';
import 'package:smart_room/wind_level_icon.dart';

class AirconPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "エアコン",
          style: NeumorphicStyle(color: Colors.black87),
          textStyle: NeumorphicTextStyle(fontSize: 20),
        ),
      ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  child: FutureBuilder(
                    future: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Temp).first,
                    builder: (_, AsyncSnapshot<String> snapshot) =>
                      ProgressBar(
                        initval: snapshot.data?.parseInt() ?? 27,
                        max: 30,
                        min: 18,
                        innerText: (value) =>
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeumorphicText(
                                value.toString() + "°",
                                style: NeumorphicStyle(
                                    color: Colors.black
                                ),
                                textStyle: NeumorphicTextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              NeumorphicText(
                                "C",
                                style: NeumorphicStyle(
                                  color: Colors.black
                                ),
                                textStyle: NeumorphicTextStyle(
                                    fontSize: 40,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ],
                          ),
                        onChangeEnd: (double value) =>
                           Provider
                             .of<AirconBloc>(context, listen: false)
                             .update(AirconBlocVars.Temp, value.toInt().toString()),
                      ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DialogButton(
                  title: "風向",
                  options: [
                    [Tuple2("swing", WindVIcon.swing), Tuple2("0", WindVIcon.l0)],
                    [Tuple2("1", WindVIcon.l1), Tuple2("2", WindVIcon.l2)],
                    [Tuple2("3", WindVIcon.l3), Tuple2("4", WindVIcon.l4)],
                    [Tuple2("5", WindVIcon.l5)]
                  ],
                  stateStream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.WindV),
                  onSelected: (value) =>
                    Provider.of<AirconBloc>(context, listen: false)
                      .update(AirconBlocVars.WindV, value),
                ),
                DialogButton(
                  title: "風量",
                  options: [
                    [Tuple2("auto", WindLevelIcon.auto), Tuple2("max", WindLevelIcon.max)],
                    [Tuple2("mid", WindLevelIcon.mid), Tuple2("min", WindLevelIcon.min)],
                  ],
                  stateStream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.WindLevel),
                  onSelected: (value) =>
                    Provider.of<AirconBloc>(context, listen: false)
                      .update(AirconBlocVars.WindLevel, value),
                ),
                NeumorphicButton(
                  child: NeumorphicIcon(
                    Icons.list,
                    size: 50,
                    style: NeumorphicStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                  },
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12)
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Timer),
                  builder: (_, snapshot) =>
                    (snapshot.data?.toString() ?? "") == "" ?
                      TimerSetPanel() : TimerEditPanel(),
                ),
             ]
            ),
          ],
        )
    );
}


class TimerSetDialog extends StatefulWidget {
  final Timer init;

  TimerSetDialog(this.init);

  @override
  _TimerSetDialogState createState() => _TimerSetDialogState();
}

class _TimerSetDialogState extends State<TimerSetDialog> {
  late Timer state;

  @override
  void initState() {
    super.initState();
    state = widget.init;
  }

  @override
  Widget build(BuildContext context) =>
    AlertDialog(
      title: Text("タイマー設定"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text(
              state.time.hm(),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 50,
                fontWeight: FontWeight.w300
              ),
            ),
            onPressed: () async {
              final result = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(state.time),
              );

              if (result != null) {
                final day = result.totalMinute() < TimeOfDay.now().totalMinute() ? state.time.day + 1 : state.time.day;
                final finishTime = DateTime(state.time.year, state.time.month, day, result.hour, result.minute);

                setState(() {
                  state.time = finishTime;
                });
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeumorphicRadio(
                style: NeumorphicRadioStyle(
                  selectedColor: Colors.white,
                  unselectedColor: Colors.white
                ),
                value: "on",
                groupValue: state.type,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(child: Text("on", style: TextStyle(fontSize: 20),)),
                ),
                onChanged: (String? value) => setState(() {
                  if (value != null) {
                    state.type = value;
                  }
                }),
              ),
              SizedBox(height: 0, width: 10),
              NeumorphicRadio(
                style: NeumorphicRadioStyle(
                    selectedColor: Colors.white,
                    unselectedColor: Colors.white
                ),
                value: "off",
                groupValue: state.type,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(child: Text("off", style: TextStyle(fontSize: 20),),),
                ),
                onChanged: (String? value) => setState(() {
                  if (value != null) {
                    state.type = value;
                  }
                }),
              ),
              SizedBox(height: 0, width: 10),
              NeumorphicRadio(
                style: NeumorphicRadioStyle(
                    selectedColor: Colors.white,
                    unselectedColor: Colors.white
                ),
                value: "sleep",
                groupValue: state.type,
                child: SizedBox(
                  height: 50,
                  width: 70,
                  child: Center(child: Text("sleep", style: TextStyle(fontSize: 20),),),
                ),
                onChanged: (String? value) => setState(() {
                  if (value != null) {
                    state.type = value;
                  }
                }),
              ),
            ],
          )
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text("cancel", style: TextStyle(color: Colors.redAccent),),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, state),
          child: Text("OK", style: TextStyle(color: Colors.black87),),
        ),
      ],
    );
}

void _showTimerPopup(BuildContext context, [Timer? init]) async {
  final Timer safeinit = init ?? Timer(time: DateTime.now(), type: "off");

  final result = await showDialog(
    context: context,
    builder: (context) =>
        TimerSetDialog(safeinit)
  );

  if (result != null) {
    Provider.of<AirconBloc>(context, listen: false).update(AirconBlocVars.Timer, result.toString());
  }
}

class TimerSetPanel extends StatefulWidget {
  @override
  _TimerSetPanelState createState() => _TimerSetPanelState();
}

class _TimerSetPanelState extends State<TimerSetPanel> {
  @override
  Widget build(BuildContext context) =>
    Expanded(
      child: NeumorphicButton(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
        onPressed: () {
          _showTimerPopup(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NeumorphicIcon(
              Icons.access_time,
              size: 40,
              style: NeumorphicStyle(
                  color: Colors.black87
              ),
            ),
            NeumorphicText(
              "タイマーなし",
              style: NeumorphicStyle(
                  color: Colors.black87
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w100
              ),
            )
          ],
        ),
      )
    );
}

class TimerEditPanel extends StatefulWidget {
  @override
  _TimerEditPanelState createState() => _TimerEditPanelState();
}

class _TimerEditPanelState extends State<TimerEditPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) =>
    Expanded(
      child: NeumorphicButton(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
          onPressed: () {
            setState(() { _expanded = !_expanded; });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicIcon(
                    Icons.access_time,
                    size: 40,
                    style: NeumorphicStyle(
                      color: Colors.black87,
                    ),
                  ),
                  StreamBuilder(
                    stream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Timer),
                    builder: (_, snapshot) {
                      if (snapshot.data == null) {
                        return Text("");
                      } else {
                        final timer = Timer.fromString(snapshot.data.toString());

                        return Row(
                          children: [
                            NeumorphicText(
                              timer.time.hm(),
                              style: NeumorphicStyle(
                                color: Colors.black,
                              ),
                              textStyle: NeumorphicTextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: 0, width: 10,),
                            NeumorphicText(
                              timer.type,
                              style: NeumorphicStyle(
                                color: Colors.black87
                              ),
                              textStyle: NeumorphicTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  ),
                  if (_expanded)
                    NeumorphicIcon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 30,
                      style: NeumorphicStyle(
                        color: Colors.black87
                      )
                    )
                ],
              ),

              if (_expanded)
                Divider(
                  color: Colors.black87,
                  thickness: 1.0,
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: NeumorphicIcon(
                            Icons.delete_outline,
                            size: 25,
                            style: NeumorphicStyle(
                                color: Colors.black87
                            ),
                          ),
                          onPressed: () {
                            Provider.of<AirconBloc>(context, listen: false).update(AirconBlocVars.Timer, "");
                          },
                        ),
                        SizedBox(height: 0, width: 10,),
                        StreamBuilder(
                          stream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Timer),
                          builder: (_, snapshot) =>
                              IconButton(
                                icon: NeumorphicIcon(
                                  Icons.edit,
                                  size: 25,
                                  style: NeumorphicStyle(
                                      color: Colors.black87
                                  ),
                                ),
                                onPressed: () {
                                  _showTimerPopup(context, Timer.fromString(snapshot.data.toString()));
                                },
                              ),
                        ),
                      ],
                    ),
                    NeumorphicIcon(
                      Icons.keyboard_arrow_up_outlined,
                      size: 30,
                      style: NeumorphicStyle(
                          color: Colors.black87
                      ),
                    ),
                  ],
                ),
            ],
          ),
      ),
    );
}