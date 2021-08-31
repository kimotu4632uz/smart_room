import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'package:smart_room/bloc/light_bloc.dart';
import 'package:smart_room/utils.dart';
import 'package:smart_room/widget/progress_bar.dart';

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
        children: [
         Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                child: FutureBuilder(
                  future: Provider.of<LightBloc>(context).getStream(LightBlocVars.Level).first,
                  builder: (_, AsyncSnapshot<String> snapshot) =>
                      ProgressBar(
                        initval: snapshot.data?.parseInt() ?? 0,
                        max: 100,
                        min: 0,
                        innerText: (value) =>
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NeumorphicText(
                                value.toString(),
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
                        onChangeEnd: (double value) =>
                          Provider
                            .of<LightBloc>(context, listen: false)
                            .update(LightBlocVars.Level, value.toInt().toString()),
                      ),
                )
              )
            ],
          ),
        ]
      )
    );
}