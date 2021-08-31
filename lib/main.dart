import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'package:smart_room/bloc/light_bloc.dart';
import 'package:smart_room/bloc/aircon_bloc.dart';
import 'package:smart_room/page/home_page.dart';
import 'package:smart_room/page/light_page.dart';
import 'package:smart_room/page/aircon_page.dart';
import 'package:smart_room/page/settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    MultiProvider(
      providers: [
        Provider<LightBloc>(
          create: (_) => LightBloc(),
          dispose: (_, LightBloc bloc) => bloc.dispose(),
        ),
        Provider<AirconBloc>(
          create: (_) => AirconBloc(),
          dispose: (_, AirconBloc bloc) => bloc.dispose(),
        ),
      ],
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          '/settings': (context) => SettingsPage(),
          "/light": (context) => LightPage(),
          "/aircon": (context) => AirconPage(),
        },
        themeMode: ThemeMode.light,
        theme: NeumorphicThemeData(
          baseColor: Color(0xffE9F0F1),
          accentColor: Colors.cyan,

          appBarTheme: NeumorphicAppBarThemeData(
            color: Color(0xffE9F0F1),
            buttonStyle: NeumorphicStyle(
              color: Color(0xffE9F0F1),
              boxShape: NeumorphicBoxShape.circle(),
              depth: 6
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            centerTitle: true,
          )
        ),
      )
    );
}
