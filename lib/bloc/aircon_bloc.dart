import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_room/utils.dart';

class Timer {
  late DateTime time;
  late String type;

  Timer({required this.time, required this.type});
  Timer.fromString(String str) {
    final part = str.split("/");
    this.time = DateTime.parse(part[0]);
    this.type = part[1];
  }

  String toString() {
    return this.time.toIso8601String() + "/" + this.type;
  }
}

enum AirconBlocVars {
  Power,
  Temp,
  WindLevel,
  WindV,
  WindH,
  Mode,
  Timer,
}

class AirconBloc {
  List<CachedBehaviorSubject> _subjects = [
    CachedBehaviorSubject("aircon_power", "false"),
    CachedBehaviorSubject("aircon_temp", "28"),
    CachedBehaviorSubject("aircon_wind_level", "auto"),
    CachedBehaviorSubject("aircon_wind_v", "swing"),
    CachedBehaviorSubject("aircon_wind_h", "swing"),
    CachedBehaviorSubject("aircon_mode", "cool"),
    CachedBehaviorSubject("aircon_timer", ""),
  ];

  AirconBloc() {
    _subjects[AirconBlocVars.Timer.index].stream.listen((value) async {
      while(true) {
        if (value == "") return;

        final finishTime = Timer.fromString(value);

        if (_subjects[AirconBlocVars.Timer.index].cache != value)
          return;

        if(DateTime.now().isAfter(finishTime.time)) {
          _subjects[AirconBlocVars.Power.index].sink.add(finishTime.type == "on" ? "true" : "false");
          _subjects[AirconBlocVars.Timer.index].sink.add("");
          return;
        }

        await Future.delayed(Duration(minutes: 1));
      }
    });
  }

  Stream<String> getStream(AirconBlocVars name) {
    return _subjects[name.index].stream;
  }

  void update(AirconBlocVars name, String value) {
    _post(name, value);
    _subjects[name.index].sink.add(value);
  }

  void dispose() {
    for (final c in _subjects) {
      c.close();
    }
  }

  Future<bool> _post(AirconBlocVars name, String value) async {
    final sp = await SharedPreferences.getInstance();
    final url = Uri.parse(sp.getString("aircon_post_url") ?? "");

    List<String> values = _subjects.map((e) => e.cache).toList();
    values[name.index] = value;

    final bodyObj = {
      "power": values[0].parseBool(),
      "temp": int.parse(values[1]),
      "wind_level": values[2],
      "wind_v": values[3],
      "wind_h": values[4],
      "mode": values[5],
    };

    if (values[AirconBlocVars.Timer.index] != "") {
      final timer = Timer.fromString(values[6]);

      bodyObj["timer_time"] = timer.time.millisecondsSinceEpoch ~/ 1000;
      bodyObj["timer_type"] = timer.type;
    }

    final body = json.encode(bodyObj);

    final resp = await http.post(url, headers: {'content-type': 'application/json'}, body: body);
    print(resp.body);
    if (resp.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }
}
