import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_room/utils.dart';

enum LightBlocVars {
  Power,
  Level,
}

class LightBloc {
  List<CachedBehaviorSubject> _subjects = [
    CachedBehaviorSubject("light_power", "true"),
    CachedBehaviorSubject("light_level", "100"),
  ];

  Stream<String> getStream(LightBlocVars name) {
    return _subjects[name.index].stream;
  }

  void update(LightBlocVars name, String value) {
    _post(name, value);
    _subjects[name.index].sink.add(value);
  }

  void dispose() {
    for (final c in _subjects) {
      c.close();
    }
  }

  Future<bool> _post(LightBlocVars name, String value) async {
    final sp = await SharedPreferences.getInstance();
    final url = Uri.parse(sp.getString("light_post_url") ?? "");

    List<String> cache = _subjects.map((e) => e.cache).toList();
    cache[name.index] = value;

    final power = cache[0].parseBool();
    final level = int.parse(cache[1]);

    final body = json.encode({"level": power ? level : 0});

    final resp = await http.post(url, headers: {'content-type': 'application/json'}, body: body);
    print(resp.body);
    if (resp.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }
}
