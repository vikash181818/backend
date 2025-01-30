// routes/productUnitRoutes.js

const express = require("express");
const verifyToken = require("../middleware/authMiddleware");
const db = require("../config/firebase");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const router = express.Router();

// Ensure the directory exists for product images
const productImgDir = path.join(__dirname, "../assets/products");
if (!fs.existsSync(productImgDir)) {
  fs.mkdirSync(productImgDir, { recursive: true });
}

// Set up multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, productImgDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`); // Add timestamp to filenames to avoid conflicts
  },
});

const upload = multer({ storage });

// Create a new product unit
router.post(
  "/product_units",
  verifyToken,
  upload.single("image"),
  async (req, res) => {
    try {
      console.log("req.body>>>>>>>>>>>>>>>>>", req.body);
      const {
        mrp,
        sale_price,
        maxQuantity,
        is_active = 1,
        is_default = 0,
        unitId,
        productId,
        base_unit_value,
        baseUnitId,
      } = req.body;

      // Handle image upload
      const image = req.file
        ? `/assets/products/${req.file.filename}`
        : null;

      console.log("image>>>>>>>>>>>>>>>>>", image);

      // Validate required fields
      if (
        !mrp ||
        !sale_price ||
        !maxQuantity ||
        !unitId ||
        !productId ||
        !base_unit_value ||
        !baseUnitId ||
        !image
      ) {
        return res.status(400).json({
          message:
            "All fields (image, mrp, sale_price, maxQuantity, unitId, productId, etc.) are required.",
        });
      }

      const productUnitData = {
        id: Date.now().toString(),
        mrp,
        sale_price,
        maxQuantity,
        image,
        is_active,
        is_default,
        unitId,
        productId,
        base_unit_value,
        baseUnitId,
        created_date: new Date().toISOString(),
        last_updated_date: new Date().toISOString(),
        createdById: req.user.id, // Get createdById from the authenticated user
        lastUpdatedById: req.user.id, // Set lastUpdatedById to the authenticated user
      };

      // Save product unit to Firestore
      await db
        .collection("product_units")
        .doc(productUnitData.id)
        .set(productUnitData);

      res.status(201).json({
        message: "Product unit created successfully!",
        productUnit: productUnitData,
      });
    } catch (error) {
      console.error("Error creating product unit:", error.message);
      res.status(500).json({
        message: "Failed to create product unit",
        error: error.message,
      });
    }
  }
);

// Edit an existing product unit
router.patch(
  "/product_units/:id",
  verifyToken,
  upload.single("image"),
  async (req, res) => {
    try {
      const { id } = req.params;
      const updates = req.body;
      const image = req.file
        ? `/assets/products/${req.file.filename}`
        : null;

      if (!id) {
        return res
          .status(400)
          .json({ message: "Product Unit ID is required." });
      }

      const docRef = db.collection("product_units").doc(id);
      const doc = await docRef.get();

      if (!doc.exists) {
        return res.status(404).json({ message: "Product Unit not found." });
      }

      if (image) {
        updates.image = image;
      }

      await docRef.update({
        ...updates,
        last_updated_date: new Date().toISOString(),
        lastUpdatedById: req.user.id, // Get lastUpdatedById from the authenticated user
      });

      res
        .status(200)
        .json({ message: "Product unit updated successfully!" });
    } catch (error) {
      console.error("Error updating product unit:", error.message);
      res.status(500).json({
        message: "Failed to update product unit",
        error: error.message,
      });
    }
  }
);

// Get all product units
router.get("/product_units", verifyToken, async (req, res) => {
  try {
    const snapshot = await db.collection("product_units").get();
    const productUnits = snapshot.docs.map((doc) => doc.data());
    res.status(200).json({ productUnits });
  } catch (error) {
    console.error("Error fetching product units:", error.message);
    res.status(500).json({
      message: "Failed to fetch product units",
      error: error.message,
    });
  }
});

// Get a specific product unit by ID
router.get("/product_units/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection("product_units").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Product Unit not found." });
    }

    res.status(200).json({ productUnit: doc.data() });
  } catch (error) {
    console.error("Error fetching product unit:", error.message);
    res.status(500).json({
      message: "Failed to fetch product unit",
      error: error.message,
    });
  }
});

module.exports = router;



