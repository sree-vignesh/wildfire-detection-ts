import express, { Request, Response } from "express";
import * as tf from "@tensorflow/tfjs-node";
import path from "path";
import sharp from "sharp";
import multer from "multer";
import cors from "cors";
import fs from "fs";

const app = express();
const PORT = 3001;

// Paths to the model directories
const model1Path = path.join(__dirname, "../model/model.json");
const model2Path = path.join(__dirname, "../model-2/model.json");

// Set up Multer for file upload handling
const upload = multer({ dest: path.resolve("src/uploads/") });

// Enable CORS (Cross-Origin Resource Sharing)
app.use(cors());

// Serve static files (e.g., index.html)
app.use(express.static(path.join(__dirname, "public")));

// Load the models once when the server starts
let model1: tf.GraphModel | null = null;
let model2: tf.GraphModel | null = null;

async function loadModels() {
  try {
    console.log("Loading models...");
    model1 = await tf.loadGraphModel(`file://${model1Path}`);
    console.log("Model 1 loaded successfully!");

    model2 = await tf.loadGraphModel(`file://${model2Path}`);
    console.log("Model 2 loaded successfully!");
  } catch (err: any) {
    console.error("Error loading models:", err);
  }
}

loadModels(); // Load the models when the server starts

// Serve a basic route
app.get("/", (req: Request, res: Response) => {
  res.send("TensorFlow.js Model Hosting Server");
});

// Endpoint to upload and process an image
app.post("/predict", upload.single("image"), async (req: any, res: any) => {
  console.log("pinged!");
  if (!req.file) {
    return res.status(400).send("No image uploaded.");
  }

  try {
    const imagePath = path.resolve(req.file.path);

    // Resize the image for Model 1
    const model1Buffer = await sharp(imagePath)
      .resize(64, 64) // Update with Model 1's expected size
      .toBuffer();

    const model1Tensor = tf.node
      .decodeImage(model1Buffer)
      .toFloat()
      .div(tf.scalar(255))
      .expandDims(0); // [1, 64, 64, 3]

    // Dynamically determine Model 2's input size
    if (!model2) {
      return res.status(500).send("Model 2 not loaded.");
    }
    const model2InputShape = model2.inputs[0].shape; // e.g., [-1, 224, 224, 3]
    const [_, height, width, _channels] = model2InputShape || [-1, 224, 224, 3];

    const model2Buffer = await sharp(imagePath)
      .resize(width, height) // Use the dimensions dynamically
      .toBuffer();

    const model2Tensor = tf.node
      .decodeImage(model2Buffer)
      .toFloat()
      .div(tf.scalar(255))
      .expandDims(0); // [1, height, width, 3]

    // Ensure both models are loaded
    if (!model1 || !model2) {
      return res.status(500).send("Models not loaded. Please try again later.");
    }

    // Run predictions for each model
    const model1Predictions = (await model1.predict(model1Tensor)) as tf.Tensor;
    const model2Predictions = (await model2.predict(model2Tensor)) as tf.Tensor;

    // Convert predictions to arrays
    const model1Output = Array.from(model1Predictions.dataSync());
    const model2Output = Array.from(model2Predictions.dataSync());

    // Clean up the uploaded image after processing
    fs.unlinkSync(imagePath);

    // Send the results
    res.json({
      "Unet Model": model1Output,
      "Auxillary Model": model2Output,
    });
  } catch (err: any) {
    console.error("Error processing image:", err);
    res.status(500).send(`Error processing image: ${err.message}`);
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
