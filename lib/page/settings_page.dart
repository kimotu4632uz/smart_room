import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:smart_room/utils.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Scaffold(
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
             FutureBuilder(
                future: SharedPreferences.getInstance().then((sp) => sp.getString("light_post_url") ?? ""),
                builder: (context, AsyncSnapshot<String> snapshot) =>
                  SettingButton(
                    title: "照明POST用URL",
                    innerText: snapshot.data ?? "",
                    icon: Icons.edit,
                    onPressed: (text, update) async {
                      final result = await showTextEditDialog(
                          context: context,
                          title: "照明",
                          init: snapshot.data
                      );

                      if (result != null) {
                        final sp = await SharedPreferences.getInstance();
                        sp.setString("light_post_url", result);
                        update(result);
                      }
                    },
                  ),
              ),
              FutureBuilder(
                future: SharedPreferences.getInstance().then((sp) => sp.getString("aircon_post_url") ?? ""),
                builder: (context, AsyncSnapshot<String> snapshot) =>
                  SettingButton(
                    title: "エアコンPOST用URL",
                    innerText: snapshot.data ?? "",
                    icon: Icons.edit,
                    onPressed: (text, update) async {
                      final result = await showTextEditDialog(
                          context: context,
                          title: "エアコン",
                          init: snapshot.data
                      );

                      if (result != null) {
                        final sp = await SharedPreferences.getInstance();
                        sp.setString("aircon_post_url", result);
                        update(result);
                      }
                    },
                  ),
              ),
              FutureBuilder(
                future: SharedPreferences.getInstance().then((sp) => sp.getString("room_get_url") ?? ""),
                builder: (context, AsyncSnapshot<String> snapshot) =>
                  SettingButton(
                    title: "部屋状態GET用URL",
                    innerText: snapshot.data ?? "",
                    icon: Icons.edit,
                    onPressed: (text, update) async {
                      final result = await showTextEditDialog(
                        context: context,
                        title: "部屋状態",
                        init: snapshot.data
                      );

                      if (result != null) {
                        final sp = await SharedPreferences.getInstance();
                        sp.setString("room_get_url", result);
                        update(result);
                      }
                    },
                  ),
              ),
              FutureBuilder(
                future: PackageInfo.fromPlatform().then((value) => value.version),
                builder: (context, AsyncSnapshot<String> snapshot) =>
                  SettingButton(
                    title: "バージョン番号",
                    innerText: snapshot.data ?? "",
                    icon: Icons.info_outline_rounded,
                    onPressed: (_, f) {},
                  )
              ),
            ],
          )
        ],
      )
    );
}


class SettingButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final String innerText;
  final void Function(String text, Function(String) update) onPressed;

  SettingButton({required this.title, required this.icon, required this.onPressed, required this.innerText});

  _SettingButtonState createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {
  String innerText = "";

  @override
  void initState() {
    super.initState();
    innerText = widget.innerText;
  }

  @override
  void didUpdateWidget(covariant SettingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    innerText = widget.innerText;
  }

  @override
  Widget build(BuildContext context) =>
      NeumorphicButton(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Container(
          width: double.infinity,
          child: Row(
            children: [
              NeumorphicIcon(
                widget.icon,
                style: NeumorphicStyle(
                  color: Colors.black87
                ),
                size: 25,
              ),
              SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeumorphicText(
                    widget.title,
                    style: NeumorphicStyle(
                      color: Colors.black87,
                    ),
                    textStyle: NeumorphicTextStyle(
                      fontSize: 18
                    ),
                  ),
                  SizedBox(height: 2),
                  NeumorphicText(
                    innerText,
                    style: NeumorphicStyle(
                      color: Colors.black45
                    ),
                    textStyle: NeumorphicTextStyle(
                      fontSize: 15
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onPressed: () => widget.onPressed(innerText, (text) => setState(() { innerText = text; })),
      );
}
