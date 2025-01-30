const express = require("express");
const verifyToken = require("../middleware/authMiddleware");
const db = require("../config/firebase");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const router = express.Router();

// Ensure the directory exists
const categoryDir = path.join(__dirname, "../assets/category");
if (!fs.existsSync(categoryDir)) {
  fs.mkdirSync(categoryDir, { recursive: true });
}

// Set up multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, categoryDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Create a new category
router.post("/categories", verifyToken, upload.single("image"), async (req, res) => {
  try {
    const { name, color, percentOff = 0, is_active = 1 } = req.body;
    const image = req.file ? `/assets/category/${req.file.filename}` : null;

    if (!name || !color || !image) {
      return res.status(400).json({ message: "name, color, and image are required." });
    }

    const categoryData = {
      id: Date.now().toString(),
      name,
      color,
      image,
      percentOff,
      is_active,
      created_date: new Date().toISOString(),
      last_updated_date: new Date().toISOString(),
      createdById: req.user.id,
      lastUpdatedById: req.user.id,
    };

    await db.collection("categories").doc(categoryData.id).set(categoryData);

    res.status(201).json({
      message: "Category created successfully!",
      category: categoryData,
    });
  } catch (error) {
    console.error("Error creating category:", error.message);
    res.status(500).json({ message: "Failed to create category", error: error.message });
  }
});

// Edit an existing category
router.patch("/categories/:id", verifyToken, upload.single("image"), async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const image = req.file ? `/assets/category/${req.file.filename}` : null;

    if (!id) {
      return res.status(400).json({ message: "Category ID is required." });
    }

    const docRef = db.collection("categories").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Category not found." });
    }

    if (image) {
      updates.image = image;
    }

    await docRef.update({
      ...updates,
      last_updated_date: new Date().toISOString(),
      lastUpdatedById: req.user.id,
    });

    res.status(200).json({ message: "Category updated successfully!" });
  } catch (error) {
    console.error("Error updating category:", error.message);
    res.status(500).json({ message: "Failed to update category", error: error.message });
  }
});

// Get all categories
router.get("/categories", verifyToken, async (req, res) => {
  try {
    const snapshot = await db.collection("categories").get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "No categories found." });
    }

    const categories = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(categories);
  } catch (error) {
    console.error("Error fetching categories:", error.message);
    res.status(500).json({ message: "Failed to fetch categories", error: error.message });
  }
});

// Get a specific category by ID
router.get("/categories/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Category ID is required." });
    }

    const docRef = db.collection("categories").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Category not found." });
    }

    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error("Error fetching category:", error.message);
    res.status(500).json({ message: "Failed to fetch category", error: error.message });
  }
});

// Delete a specific category by ID
router.delete("/categories/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Category ID is required." });
    }

    const docRef = db.collection("categories").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Category not found." });
    }

    await docRef.delete();

    res.status(200).json({ message: "Category deleted successfully!" });
  } catch (error) {
    console.error("Error deleting category:", error.message);
    res.status(500).json({ message: "Failed to delete category", error: error.message });
  }
});

router.get("/search_categories",async (req, res) => {
  try {
    const { searchTerm } = req.query; // Extract the search term from query params

    // Fetch all categories
    const snapshot = await db.collection("categories").get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "No categories found." });
    }

    const categories = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((category) => {
        // Check if the search term matches the name or color (case-insensitive)
        return (
          searchTerm &&
          (category.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            category.color.toLowerCase().includes(searchTerm.toLowerCase()))
        );
      });

    if (categories.length === 0) {
      return res.status(404).json({ message: "No matching categories found." });
    }

    res.status(200).json(categories);
  } catch (error) {
    console.error("Error searching categories:", error.message);
    res.status(500).json({ message: "Failed to search categories", error: error.message });
  }
});

module.exports = router;
