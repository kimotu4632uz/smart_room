import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'LightBloc.dart';

class LightPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "照明",
          style: NeumorphicStyle(color: Colors.black87),
          textStyle: NeumorphicTextStyle(fontSize: 20),
        )
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
                  stream: Provider.of<LightBloc>(context).getStream(LightBlocVars.Level),
                  builder: (_, snapshot) {
                    if (snapshot.data == null) {
                      return Text("");
                    } else {
                      return ProgressBar(
                        initval: int.parse(snapshot.data.toString()),
                        max: 100,
                        min: 0,
                        onChangeEnd: (double value) =>
                            Provider
                                .of<LightBloc>(context, listen: false)
                                .update(LightBlocVars.Level, value.toInt().toString()),
                      );
                    }
                  }
                )
              )
            ],
          ),
        ]
      )
    );
}


class ProgressBar extends StatefulWidget {
  final int initval, max, min;
  final Function(double) onChangeEnd;

  ProgressBar({required this.initval, required this.max, required this.min, required this.onChangeEnd});

  @override
  _ProgressBarStatus createState() => _ProgressBarStatus();
}

class _ProgressBarStatus extends State<ProgressBar> {
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
          children: [
            NeumorphicText(
              _progress.toString(),
              style: NeumorphicStyle(
                  color: Colors.black
              ),
              textStyle: NeumorphicTextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w300,
              ),
            ),
            NeumorphicText(
                    "%",
                    style: NeumorphicStyle(
                      color: Colors.black
                    ),
                    textStyle: NeumorphicTextStyle(
                        fontSize: 30
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

            depth: -10,
          ),
        )
      ],
    );
}
