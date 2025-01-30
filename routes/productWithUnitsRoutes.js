// routes/productWithUnitsRoutes.js

const express = require("express");
const verifyToken = require("../middleware/authMiddleware");
const db = require("../config/firebase");

const router = express.Router();

// Get all products with their related product units
router.get("/products_with_units", verifyToken, async (req, res) => {
  try {
    const productSnapshot = await db.collection("products").get();

    if (productSnapshot.empty) {
      return res.status(404).json({ message: "No products found." });
    }

    const products = [];

    for (const doc of productSnapshot.docs) {
      const productData = { id: doc.id, ...doc.data() };

      // Fetch related product units
      const productUnitsSnapshot = await db
        .collection("product_units")
        .where("productId", "==", productData.id)
        .get();

      const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

      // Combine product data with its units
      products.push({
        ...productData,
        productUnits,
      });
    }

    res.status(200).json(products);
  } catch (error) {
    console.error("Error fetching products with units:", error.message);
    res.status(500).json({
      message: "Failed to fetch products with units",
      error: error.message,
    });
  }
});

// Get a specific product by ID along with its product units
router.get("/products_with_units/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    const productDoc = await db.collection("products").doc(id).get();

    if (!productDoc.exists) {
      return res.status(404).json({ message: "Product not found." });
    }

    const productData = { id: productDoc.id, ...productDoc.data() };

    // Fetch related product units
    const productUnitsSnapshot = await db
      .collection("product_units")
      .where("productId", "==", productData.id)
      .get();

    const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

    // Combine product data with its units
    const result = {
      ...productData,
      productUnits,
    };

    res.status(200).json(result);
  } catch (error) {
    console.error("Error fetching product with units:", error.message);
    res.status(500).json({
      message: "Failed to fetch product with units",
      error: error.message,
    });
  }
});


// Delete a specific product unit by ID within a specific product
router.delete("/products/:productId/product_units/:unitId", verifyToken, async (req, res) => {

  console.log(req.params);

  try {
    const { productId, unitId } = req.params;

    // Fetch the product unit document
    const unitDocRef = db.collection("product_units").doc(unitId);
    const unitDoc = await unitDocRef.get();

    if (!unitDoc.exists) {
      return res.status(404).json({ message: "Product unit not found." });
    }

    const unitData = unitDoc.data();

    // Verify that the unit belongs to the specified product
    if (unitData.productId !== productId) {
      return res.status(400).json({ message: "Product unit does not belong to the specified product." });
    }

    // Delete the product unit
    await unitDocRef.delete();

    res.status(200).json({ message: "Product unit deleted successfully." });
  } catch (error) {
    console.error("Error deleting product unit:", error.message);
    res.status(500).json({
      message: "Failed to delete product unit",
      error: error.message,
    });
  }
});


router.get("/products_with_units_by_category/:categoryId", verifyToken, async (req, res) => {
  try {
    const { categoryId } = req.params;
    const productSnapshot = await db.collection("products").where("typeId", "==", categoryId).get();

    if (productSnapshot.empty) {
      return res.status(404).json({ message: "No products found for this category." });
    }
    const products = [];
    for (const doc of productSnapshot.docs) {
      const productData = { id: doc.id, ...doc.data() };
      const productUnitsSnapshot = await db.collection("product_units").where("productId", "==", productData.id).get();
      const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());
      products.push({ ...productData, productUnits, });
    }
    res.status(200).json(products);
  }
  catch (error) {
    console.error("Error fetching products by category with units:", error.message);
    res.status(500).json({ message: "Failed to fetch products by category", error: error.message, });
  }
});






module.exports = router;



