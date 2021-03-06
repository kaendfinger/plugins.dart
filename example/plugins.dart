import 'package:plugins/loader.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

void main() {
  PluginManager pm = new PluginManager();
  Directory path = new Directory(Path.joinAll(["example", "plugins"]));
  int killReady = 0;

  pm.loadAll(path, followLinks: false).then((List<Plugin> plugins) {
    print("[Plugins] Plugins registered: ${plugins}");

    pm.listenAllRequest((String plugin, Request req) {
      if (req.command == "test") {
        req.reply({ "should": true });
        return;
      } else if (req.command == "test-nocall") {
        req.reply({ "should": false });
        return;
      }
      print("[Plugins] Received request from '$plugin' for command '${req.command}'");
      req.reply({0: 'Isn\'t this just awesome?'});
    });

    pm.listenAll((name, data) {
      if (data[0] == "KILL") {
        killReady++;
        if (pm.plugins.length == killReady) {
          print("[Plugins] Ready to kill all plugins!");
          pm.killAll();
        }
      } else {
        print("[Plugins] Received data from plugin '$name': ${data[0]}");
      }
    });

    pm.send("Test", {0: "Hello from loader!"});
    pm.get("Requester", "loader-command", {}).then((Map data) {
      print("[Plugins] ${data[0]}");
    });
  });
}
