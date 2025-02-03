import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String _serverUrlKey = "server_url";
  static const String _serverPortKey = "server_port";

  // Save the server URL
  static Future<void> setServerUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  // Get the server URL
  static Future<String> getServerUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey) ?? "http://10.0.2.2";
  }

  // Save the server Port
  static Future<void> setServerPort(String port) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverPortKey, port);
  }

  // Get the server Port
  static Future<String> getServerPort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverPortKey) ?? "3001";
  }
}
