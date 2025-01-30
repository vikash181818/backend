const express = require("express");

const verifyToken = require("../middleware/authMiddleware");

const db = require("../config/firebase"); // Import Firestore instance

const router = express.Router();

// Route to filter product units by selected product IDs and category ID
router.post("/filter_product_units_by_category", verifyToken, async (req, res) => {
    try {
      const { productIds, categoryId } = req.body;
  
      // Validate inputs
      if (!productIds || !Array.isArray(productIds) || productIds.length === 0) {
        return res.status(400).json({ message: "Product IDs are required and must be an array." });
      }
  
      if (!categoryId) {
        return res.status(400).json({ message: "Category ID is required." });
      }
  
      // Fetch products based on provided product IDs
      const productsSnapshot = await db
        .collection("products")
        .where("id", "in", productIds)
        .get();
  
      if (productsSnapshot.empty) {
        return res.status(404).json({ message: "No matching products found." });
      }
  
      const filteredProducts = [];
  
      for (const productDoc of productsSnapshot.docs) {
        const productData = { id: productDoc.id, ...productDoc.data() };
  
        // Check if the product belongs to the selected category
        if (productData.typeId === categoryId) {
          // Fetch related product units
          const productUnitsSnapshot = await db
            .collection("product_units")
            .where("productId", "==", productData.id)
            .get();
  
          const productUnits = productUnitsSnapshot.docs.map((unitDoc) => ({
            id: unitDoc.id,
            ...unitDoc.data(),
          }));
  
          // Combine product data with its units
          filteredProducts.push({
            ...productData,
            productUnits,
          });
        }
      }
  
      if (filteredProducts.length === 0) {
        return res.status(404).json({ message: "No matching products found for the selected category." });
      }
  
      res.status(200).json(filteredProducts);
    } catch (error) {
      console.error("Error filtering products with units by category:", error);
      res.status(500).json({ message: "An error occurred while processing your request." });
    }
});

module.exports = router;
