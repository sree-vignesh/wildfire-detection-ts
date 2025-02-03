import 'package:flutter/material.dart';
import '../utils/settings_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    String url = await SettingsManager.getServerUrl();
    String port = await SettingsManager.getServerPort();
    setState(() {
      _serverUrlController.text = url;
      _serverPortController.text = port;
    });
  }

  // Save settings
  Future<void> _saveSettings() async {
    await SettingsManager.setServerUrl(_serverUrlController.text);
    await SettingsManager.setServerPort(_serverPortController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Ensure build method is present
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: "Server URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _serverPortController,
              decoration: const InputDecoration(
                labelText: "Server Port",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
