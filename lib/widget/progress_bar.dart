import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class ProgressBar extends StatefulWidget {
  final int initval, max, min;
  final void Function(double) onChangeEnd;
  final Widget Function(int) innerText;

  ProgressBar({required this.initval, required this.max, required this.min, required this.onChangeEnd, required this.innerText});

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
  void didUpdateWidget(covariant ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    this._progress = widget.initval;
  }

  @override
  Widget build(BuildContext context) =>
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        widget.innerText(_progress),
        NeumorphicSlider(
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          value: _progress.toDouble(),
          height: 25,
          onChanged: (double value) {
            if (value.toInt() != _progress) {
              setState(() {
                _progress = value.toInt();
              });
            }
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
