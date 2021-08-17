import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'AirconBloc.dart';
import 'utils.dart';
import 'wind_v_icon_icons.dart';
import 'wind_level_icon_icons.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  child: StreamBuilder(
                    stream: Provider.of<AirconBloc>(context).getStream(AirconBlocVars.Temp),
                    builder: (_, snapshot) {
                      if (snapshot.data == null) {
                        return Text("");
                      } else{
                        return ProgressBar(
                          initval: int.parse(snapshot.data.toString()),
                          max: 30,
                          min: 18,
                          onChangeEnd: (double value) =>
                             Provider
                                 .of<AirconBloc>(context, listen: false)
                                 .update(AirconBlocVars.Temp, value.toInt().toString()),
                        );
                      }
                    }
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DialogButton(
                  "風向",
                  [
                    [
                      Tuple2("swing", WindVIcon.swing),
                      Tuple2("0", WindVIcon.l0)
                    ],
                    [Tuple2("1", WindVIcon.l1), Tuple2("2", WindVIcon.l2)],
                    [Tuple2("3", WindVIcon.l3), Tuple2("4", WindVIcon.l4)],
                    [Tuple2("5", WindVIcon.l5)]
                  ],
                  AirconBlocVars.WindV
                ),
                DialogButton(
                  "風量",
                  [
                    [
                      Tuple2("auto", WindLevelIcon.auto),
                      Tuple2("max", WindLevelIcon.max)
                    ],
                    [
                      Tuple2("mid", WindLevelIcon.mid),
                      Tuple2("min", WindLevelIcon.min)
                    ],
                  ],
                  AirconBlocVars.WindLevel
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
                  builder: (_, snapshot) {
                    return (snapshot.data?.toString() ?? "") == "" ?
                    TimerSetPanel() : TimerEditPanel();
                  }
                ),
             ]
            ),
          ],
        )
    );
}


class ProgressBar extends StatefulWidget {
  final int initval, max, min;
  final Function(double) onChangeEnd;

  ProgressBar({required this.initval, required this.max, required this.min, required this.onChangeEnd});

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    this._progress = widget.initval;
  }

  @override
  Widget build(BuildContext context) =>
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NeumorphicText(
              _progress.toString() + "°",
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
        NeumorphicSlider(
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          value: _progress.toDouble(),
          height: 25,
          onChanged: (double value) {
            setState(() {
              _progress = value.toInt();
            });
          },
          onChangeEnd: widget.onChangeEnd,
          style: SliderStyle(
            accent: Colors.black87,
            variant: Colors.black87,
            depth: -20,
          ),
        )
      ],
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
              final time_result = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(state.time),
              );

              if (time_result != null) {
                final day = time_result.totalMinute() < TimeOfDay.now().totalMinute() ? state.time.day + 1 : state.time.day;
                final finish_time = DateTime(state.time.year, state.time.month, day, time_result.hour, time_result.minute);

                setState(() {
                  state.time = finish_time;
                });;
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
  final Timer init_safe = init ?? Timer(time: DateTime.now(), type: "off");

  final result = await showDialog(
    context: context,
    builder: (context) =>
        TimerSetDialog(init_safe)
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
          onPressed: () { setState(() {
            _expanded = !_expanded;
          }); },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: build_child(_expanded),
          ),
        ),
    );

  List<Widget> build_child(expanded) {
    final List<Widget> header = [
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
          expanded ? Text("") : NeumorphicIcon(
            Icons.keyboard_arrow_down_outlined,
            size: 30,
            style: NeumorphicStyle(
              color: Colors.black87
            )
          )
        ],
      )
    ];

    if (expanded) {
      header.add(
        Divider(
          color: Colors.black87,
          thickness: 1.0,
          height: 20,
        )
      );

      header.add(
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
        )
      );
    }

    return header;
  }
}

class DialogButton extends StatelessWidget {
  final List<List<Tuple2<String, IconData>>> options;
  final String dialog_title;
  final Map<String, IconData> iconmap;
  final AirconBlocVars varname;

  DialogButton(this.dialog_title, this.options, this.varname)
      : this.iconmap = Map.fromIterable(options.expand((i) => i),
            key: (e) => e.item1, value: (e) => e.item2);

  @override
  Widget build(BuildContext context) =>
    NeumorphicButton(
      child: StreamBuilder(
        stream: Provider.of<AirconBloc>(context).getStream(varname),
        builder: (_, snapshot) => NeumorphicIcon(
          iconmap[snapshot.data.toString()] ?? Icons.list,
          size: 50,
          style: NeumorphicStyle(color: Colors.black),
        ),
      ),
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: 6,
      ),
      onPressed: () async {
        final result = await showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return SimpleDialog(title: Text(dialog_title), children: [
                Column(
                    children: options
                        .map((options_r) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: options_r
                                .map((option) => SimpleDialogOption(
                                      child: Icon(
                                        option.item2,
                                        size: 50,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, option.item1),
                                    ))
                                .toList()))
                        .toList())
              ]);
            });

        if (result != null) {
          Provider.of<AirconBloc>(context, listen: false)
              .update(varname, result);
        }
      },
    );
}
