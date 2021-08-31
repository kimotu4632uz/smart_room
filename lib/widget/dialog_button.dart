import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:tuple/tuple.dart';

class DialogButton extends StatelessWidget {
  final List<List<Tuple2<String, IconData>>> options;
  final String title;
  final Map<String, IconData> iconmap;
  final Stream<String> stateStream;
  final void Function(String) onSelected;

  DialogButton({required this.title, required this.options, required this.stateStream, required this.onSelected})
      : this.iconmap = Map.fromIterable(options.expand((i) => i),
            key: (e) => e.item1, value: (e) => e.item2);

  @override
  Widget build(BuildContext context) =>
    NeumorphicButton(
      child: StreamBuilder(
        stream: stateStream,
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
              return SimpleDialog(title: Text(title), children: [
                Column(
                    children: options
                        .map((optionTuple) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: optionTuple
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
          onSelected(result);
        }
      },
    );
}