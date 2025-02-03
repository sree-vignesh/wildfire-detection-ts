import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'settings_provider.dart';
import 'package:provider/provider.dart';

class UploadProvider extends ChangeNotifier {
  File? _image;
  bool _isUploading = false;
  Map<String, dynamic>? _predictions;
  String? uploadedImageUrl;

  File? get image => _image;
  bool get isUploading => _isUploading;
  Map<String, dynamic>? get predictions => _predictions;

  final picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      uploadedImageUrl = null;
      _predictions = null;
      notifyListeners(); // 🔄 Notify UI
    }
  }

  // Upload image to server
  Future<void> uploadImage(BuildContext context) async {
    if (_image == null) return;

    _isUploading = true;
    notifyListeners();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    var uri = Uri.parse('${settings.serverUrl}:${settings.serverPort}/predict');

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        _predictions = json.decode(responseData);
        uploadedImageUrl = _image!.path;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isUploading = false;
      notifyListeners(); // 🔄 Notify UI
    }
  }
}
