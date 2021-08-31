import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

extension IntParsing on String {
  int parseInt() {
    return int.parse(this);
  }
}

extension Format on DateTime {
  String hm() {
    return this.hour.toString().padLeft(2, "0") + ":" +
        this.minute.toString().padLeft(2, "0");
  }
}

extension Minutes on TimeOfDay {
  int totalMinute() {
    return (this.hour * 60) + this.minute;
  }
}

class CachedBehaviorSubject {
  final _innerSubject = BehaviorSubject<String>();
  String _cache;

  Stream<String> get stream => _innerSubject.stream;
  StreamSink<String> get sink => _innerSubject.sink;
  String get cache => _cache;

  void close() {
    _innerSubject.close();
  }

  CachedBehaviorSubject(String name, String init) : _cache = init {
    _innerSubject.stream.listen((value) async {
      _cache = value;
      final sp = await SharedPreferences.getInstance();
      sp.setString(name, value);
    });

    SharedPreferences.getInstance().then((sp) {
      _innerSubject.sink.add(sp.getString(name) ?? init);
    });
  }
}
