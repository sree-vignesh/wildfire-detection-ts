import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _serverUrl = "http://10.0.2.2";
  String _serverPort = "3001";

  String get serverUrl => _serverUrl;
  String get serverPort => _serverPort;

  SettingsProvider() {
    _loadSettings();
  }

  // Load server URL & port from storage
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString("server_url") ?? _serverUrl;
    _serverPort = prefs.getString("server_port") ?? _serverPort;
    notifyListeners();
  }

  // Update & save server settings
  Future<void> setServerSettings(String url, String port) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("server_url", url);
    await prefs.setString("server_port", port);
    _serverUrl = url;
    _serverPort = port;
    notifyListeners(); // 🔄 Notify UI about changes
  }
}
