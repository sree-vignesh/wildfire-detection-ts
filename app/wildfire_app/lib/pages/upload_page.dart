import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/upload_provider.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    var uploadProvider = Provider.of<UploadProvider>(context);

    Color getFireStatusColor() {
      if (uploadProvider.predictions == null)
        return Colors.grey; // Default color when no predictions

      double model1Prediction = 0.0;
      if (uploadProvider.predictions!["model1"] is List &&
          (uploadProvider.predictions!["model1"] as List).isNotEmpty) {
        model1Prediction =
            (uploadProvider.predictions!["model1"] as List)[0].toDouble();
      }

      double model2Prediction = 0.0;
      if (uploadProvider.predictions!["model2"] is List &&
          (uploadProvider.predictions!["model2"] as List).isNotEmpty &&
          (uploadProvider.predictions!["model2"] as List).length > 1) {
        model2Prediction =
            (uploadProvider.predictions!["model2"] as List)[1].toDouble();
      }

      // 🔥 If either model predicts fire, return red, otherwise return green
      return (model1Prediction < 0.5 || model2Prediction < 0.5)
          ? Colors.red // Fire Detected
          : Colors.green; // No Fire Detected
    }

    // 🔥 Function to determine fire detection status
    String getFireStatus() {
      if (uploadProvider.predictions == null) return "Awaiting prediction...";

      // Extract Model 1 output from index 0
      double model1Prediction = 0.0;
      if (uploadProvider.predictions!["model1"] is List &&
          (uploadProvider.predictions!["model1"] as List).isNotEmpty) {
        model1Prediction =
            (uploadProvider.predictions!["model1"] as List)[0].toDouble();
      }

      // Extract Model 2 output from index 1
      double model2Prediction = 0.0;
      if (uploadProvider.predictions!["model2"] is List &&
          (uploadProvider.predictions!["model2"] as List).length > 1) {
        model2Prediction =
            (uploadProvider.predictions!["model2"] as List)[1].toDouble();
      }

      // Compare values correctly
      String model1Status =
          model1Prediction < 0.5 ? " Fire Detected" : " No Fire Detected";
      String model2Status =
          model2Prediction < 0.5 ? " Fire Detected" : " No Fire Detected";

      return "Model 1: $model1Status\nModel 2: $model2Status";
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text()
              // 🖼 Image Preview
              if (uploadProvider.image != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      uploadProvider.image!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // 📤 Upload Button
              ElevatedButton(
                onPressed: () async {
                  await uploadProvider.pickImage();
                  if (uploadProvider.image != null) {
                    await uploadProvider.uploadImage(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: uploadProvider.isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Select & Upload Image',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 20),

              // 🔥 Fire Detection Status (Color Changes Based on Output)
              if (uploadProvider.predictions != null)
                Column(
                  children: [
                    Text(
                      getFireStatus(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            getFireStatusColor(), // 🔥 Dynamic color based on fire detection
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              // 📊 Expandable Predictions Card (Fixed Overflow Issue)
              if (uploadProvider.predictions != null)
                Card(
                  elevation: 16,
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ExpansionTile(
                    title: const Text(
                      "Model Predictions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    maintainState: true, // ✅ Keeps expanded state
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // 📜 Scrollable Predictions List (Fixed Overflow)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: uploadProvider.predictions!.length,
                          itemBuilder: (context, index) {
                            var entry = uploadProvider.predictions!.entries
                                .elementAt(index);

                            // 🛠 Extract and convert value safely
                            double value = 0.0;
                            if (entry.value is List && entry.value.isNotEmpty) {
                              value = (entry.value as List)[index].toDouble();
                            } else if (entry.value is num) {
                              value = entry.value.toDouble();
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ✅ Ensure key text does not overflow
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      entry.key,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  // ✅ Ensure value text does not overflow & is formatted correctly
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      value.toStringAsFixed(
                                          6), // ✅ Format number to 2 decimal places
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // backgroundColor: Colors.grey,
                                        color: value < 0.5
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
