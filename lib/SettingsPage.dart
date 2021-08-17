import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          "Settings",
          style: NeumorphicStyle(color: Colors.black87),
          textStyle: NeumorphicTextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              NeumorphicButton(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  children: [
                    NeumorphicText(
                      "エアコンpost先URL",
                      style: NeumorphicStyle(
                        color: Colors.black87,
                      ),
                      textStyle: NeumorphicTextStyle(
                        fontSize: 20
                      ),
                    ),
                    FutureBuilder(
                      future: SharedPreferences.getInstance().then((sp) => sp.getString("aircon_post_url") ?? ""),
                      builder: (_, AsyncSnapshot<String> snapshot) =>
                        NeumorphicText(
                          snapshot.data ?? "",
                          style: NeumorphicStyle(
                            color: Colors.black45
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 15
                          ),
                        ),
                    )
                  ],
                ),
                onPressed: () async {
                  final aircon_post_url = TextEditingController();

                  final result = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context, aircon_post_url.text),
                          ),
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("エアコン"),
                            TextField(
                              controller: aircon_post_url,
                            )
                          ]
                        ),
                      )
                  );

                  if (result != null) {
                    final sp = await SharedPreferences.getInstance();
                    sp.setString("aircon_post_url", result);
                  }
                },
              ),
              NeumorphicButton(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  children: [
                    NeumorphicText(
                      "照明post先URL",
                      style: NeumorphicStyle(
                        color: Colors.black87,
                      ),
                      textStyle: NeumorphicTextStyle(
                        fontSize: 20
                      ),
                    ),
                    FutureBuilder(
                      future: SharedPreferences.getInstance().then((sp) => sp.getString("light_post_url") ?? ""),
                      builder: (_, AsyncSnapshot<String> snapshot) =>
                        NeumorphicText(
                          snapshot.data ?? "",
                          style: NeumorphicStyle(
                            color: Colors.black45
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 15
                          ),
                        ),
                    )
                  ],
                ),
                onPressed: () async {
                  final light_post_url = TextEditingController();

                  final result = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context, light_post_url.text),
                          ),
                        ],
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("照明"),
                            TextField(
                              controller: light_post_url,
                            )
                          ]
                        ),
                      )
                  );

                  if (result != null) {
                    final sp = await SharedPreferences.getInstance();
                    sp.setString("light_post_url", result);
                  }
                },
              ),
              NeumorphicButton(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  children: [
                    NeumorphicText(
                      "部屋状態get先URL",
                      style: NeumorphicStyle(
                        color: Colors.black87,
                      ),
                      textStyle: NeumorphicTextStyle(
                        fontSize: 20
                      ),
                    ),
                    FutureBuilder(
                      future: SharedPreferences.getInstance().then((sp) => sp.getString("room_get_url") ?? ""),
                      builder: (_, AsyncSnapshot<String> snapshot) =>
                        NeumorphicText(
                          snapshot.data ?? "",
                          style: NeumorphicStyle(
                            color: Colors.black45
                          ),
                          textStyle: NeumorphicTextStyle(
                            fontSize: 15
                          ),
                        ),
                    )
                  ],
                ),
                onPressed: () async {
                  final room_get_url = TextEditingController();

                  final result = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context, room_get_url.text),
                          ),
                        ],
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("部屋状態"),
                            TextField(
                              controller: room_get_url,
                            )
                          ]
                        ),
                      )
                  );

                  if (result != null) {
                    final sp = await SharedPreferences.getInstance();
                    sp.setString("room_get_url", result);
                  }
                },
              )
            ],
          )
        ],
      )
    );
  }
}