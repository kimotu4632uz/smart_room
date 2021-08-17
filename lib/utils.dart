import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

extension Format on DateTime {
  String hm() {
    return this.hour.toString().padLeft(2, "0") + ":" + this.minute.toString().padLeft(2, "0");
  }

  int totalMinute() {
    return (this.hour * 60) + this.minute;
  }
}

class CachedBehaviorSubject {
  final _inner_subject = BehaviorSubject<String>();
  String _cache;

  Stream<String> get stream => _inner_subject.stream;
  StreamSink<String> get sink => _inner_subject.sink;
  String get cache => _cache;

  void close() {
    _inner_subject.close();
  }

  CachedBehaviorSubject(String name, String init) : _cache = init {
    _inner_subject.stream.listen((value) async {
      _cache = value;
      final sp = await SharedPreferences.getInstance();
      sp.setString(name, value);
    });

    SharedPreferences.getInstance().then((sp) {
      _inner_subject.sink.add(sp.getString(name) ?? init);
    });
  }
}
