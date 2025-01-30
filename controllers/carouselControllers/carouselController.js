const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const db = admin.firestore();

// Upload a new carousel image
exports.uploadCarouselImage = async (req, res) => {
  try {
    const { order } = req.body;
    const file = req.file;

    if (!file) return res.status(400).json({ message: "Image file is required" });
    if (!order) return res.status(400).json({ message: "Order is required" });

    console.log("Uploaded file details:", file); // Log uploaded file details

    const imageName = file.originalname;
    const imagePath = `/assets/carousel/${file.filename}`;

    const carouselData = {
      id: Date.now().toString(),
      name: imageName,
      path: imagePath,
      order: parseInt(order, 10),
      created_date: new Date().toISOString(),
      last_updated_date: new Date().toISOString(),
    };

    // Save carousel data to Firestore
    await db.collection("carouselImages").doc(carouselData.id).set(carouselData);

    res.status(201).json({ message: "Carousel image uploaded successfully", carousel: carouselData });
  } catch (error) {
    console.error("Error uploading carousel image:", error.message);
    res.status(500).json({ message: "Failed to upload carousel image", error: error.message });
  }
};

// Get all carousel images (Admin)
exports.getAllCarouselImages = async (req, res) => {
  try {
    const snapshot = await db.collection("carouselImages").get();
    const carouselImages = snapshot.docs.map((doc) => doc.data());
    res.status(200).json({ carouselImages });
  } catch (error) {
    console.error("Error fetching carousel images:", error.message);
    res.status(500).json({ message: "Failed to fetch carousel images", error: error.message });
  }
};

// Get a specific carousel image by ID (Admin)
exports.getCarouselImageById = async (req, res) => {
  try {
    const { id } = req.params;

    const docRef = db.collection("carouselImages").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) return res.status(404).json({ message: "Carousel image not found" });

    res.status(200).json({ carousel: doc.data() });
  } catch (error) {
    console.error("Error fetching carousel image:", error.message);
    res.status(500).json({ message: "Failed to fetch carousel image", error: error.message });
  }
};

// Update a carousel image
exports.updateCarouselImage = async (req, res) => {
  try {
    const { id } = req.params;
    const { order, name } = req.body;
    const file = req.file;

    const docRef = db.collection("carouselImages").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) return res.status(404).json({ message: "Carousel image not found" });

    const updates = { last_updated_date: new Date().toISOString() };
    if (order) updates.order = parseInt(order, 10);
    if (name) updates.name = name;
    if (file) {
      // Replace the image
      const newImagePath = `/assets/carousel/${file.filename}`;
      const { path: oldImagePath } = doc.data();

      // Delete old image from the filesystem
      const absolutePath = path.join(__dirname, `../../${oldImagePath}`);
      if (fs.existsSync(absolutePath)) {
        fs.unlinkSync(absolutePath);
      }

      updates.path = newImagePath;
    }

    await docRef.update(updates);

    res.status(200).json({ message: "Carousel image updated successfully" });
  } catch (error) {
    console.error("Error updating carousel image:", error.message);
    res.status(500).json({ message: "Failed to update carousel image", error: error.message });
  }
};

// Delete a carousel image
exports.deleteCarouselImage = async (req, res) => {
  try {
    const { id } = req.params;

    const docRef = db.collection("carouselImages").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) return res.status(404).json({ message: "Carousel image not found" });

    const { path: imagePath } = doc.data();
    const absolutePath = path.join(__dirname, `../../${imagePath}`);

    // Delete image from the filesystem
    if (fs.existsSync(absolutePath)) {
      fs.unlinkSync(absolutePath);
    } else {
      console.warn(`File not found at path: ${absolutePath}`);
    }

    await docRef.delete();

    res.status(200).json({ message: "Carousel image deleted successfully" });
  } catch (error) {
    console.error("Error deleting carousel image:", error.message);
    res.status(500).json({ message: "Failed to delete carousel image", error: error.message });
  }
};

// Get carousel images for users (sorted by order)
exports.getCarouselImagesForUsers = async (req, res) => {
  try {
    const snapshot = await db.collection("carouselImages").orderBy("order").get();
    const carouselImages = snapshot.docs.map((doc) => doc.data());
    res.status(200).json({ carouselImages });
  } catch (error) {
    console.error("Error fetching carousel images for users:", error.message);
    res.status(500).json({ message: "Failed to fetch carousel images", error: error.message });
  }
};
