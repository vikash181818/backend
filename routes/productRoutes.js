const express = require("express");
const verifyToken = require("../middleware/authMiddleware");
const db = require("../config/firebase");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const router = express.Router();

// Ensure the directory exists
const productDir = path.join(__dirname, "../assets/products");
if (!fs.existsSync(productDir)) {
  fs.mkdirSync(productDir, { recursive: true });
}

// Set up multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, productDir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

// Create a new product
router.post("/products", verifyToken, upload.single("image"), async (req, res) => {
  try {
    const {
      id,
      name,
      description,
      offer = null,
      is_active = 1,
      created_date,
      last_updated_date,
      couponId,
      brandId,
      typeId,
      is_pluxee = 0,
      gst_rate = 0,
      is_new_launch = 0,
      is_seasonal = 0,
      is_Recommendad = 0,
      hsn_code,
    } = req.body;

    // Handle image upload
    const image = req.file ? `/assets/products/${req.file.filename}` : null;

    // Validate required fields
    if (!name || !typeId) {
      return res.status(400).json({ message: "name and typeId (category ID) are required." });
    }

    const productData = {
      id: id || Date.now().toString(),
      name,
      description,
      offer,
      is_active,
      created_date: created_date || new Date().toISOString(),
      last_updated_date: last_updated_date || new Date().toISOString(),
      couponId,
      image,  // Save the image path
      createdById: req.user.id,  // Set createdById from the authenticated user
      lastUpdatedById: req.user.id,  // Set lastUpdatedById from the authenticated user
      brandId,
      typeId,
      is_pluxee,
      gst_rate,
      is_new_launch,
      is_seasonal,
      is_Recommendad,
      hsn_code,
    };

    // Save product to Firestore
    await db.collection("products").doc(productData.id).set(productData);

    res.status(201).json({
      message: "Product created successfully!",
      product: productData,
    });
  } catch (error) {
    console.error("Error creating product:", error.message);
    res.status(500).json({ message: "Failed to create product", error: error.message });
  }
});

// Edit an existing product
router.patch("/products/:id", verifyToken, upload.single("image"), async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const image = req.file ? `/assets/products/${req.file.filename}` : null;

    if (!id) {
      return res.status(400).json({ message: "Product ID is required." });
    }

    const docRef = db.collection("products").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Product not found." });
    }

    if (image) {
      updates.image = image;
    }

    // Update the product with new values
    await docRef.update({
      ...updates,
      last_updated_date: new Date().toISOString(),
      lastUpdatedById: req.user.id,  // Set lastUpdatedById from the authenticated user
    });

    res.status(200).json({ message: "Product updated successfully!" });
  } catch (error) {
    console.error("Error updating product:", error.message);
    res.status(500).json({ message: "Failed to update product", error: error.message });
  }
});

// Get all products
router.get("/products", verifyToken, async (req, res) => {
  try {
    const snapshot = await db.collection("products").get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "No products found." });
    }

    const products = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(products);
  } catch (error) {
    console.error("Error fetching products:", error.message);
    res.status(500).json({ message: "Failed to fetch products", error: error.message });
  }
});

// Get a specific product by ID
router.get("/products/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Product ID is required." });
    }

    const docRef = db.collection("products").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Product not found." });
    }

    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error("Error fetching product:", error.message);
    res.status(500).json({ message: "Failed to fetch product", error: error.message });
  }
});

// Delete a specific product by ID
router.delete("/products/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Product ID is required." });
    }

    const docRef = db.collection("products").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Product not found." });
    }

    await docRef.delete();

    res.status(200).json({ message: "Product deleted successfully!" });
  } catch (error) {
    console.error("Error deleting product:", error.message);
    res.status(500).json({ message: "Failed to delete product", error: error.message });
  }
});

// Search products with units (additional logic for product search)
router.get("/search_products_with_units", verifyToken, async (req, res) => {
  try {
    const { searchTerm } = req.query; // Extract the search term from query params

    // Fetch all products
    const productSnapshot = await db.collection("products").get();

    if (productSnapshot.empty) {
      return res.status(404).json({ message: "No products found." });
    }

    const products = [];

    for (const doc of productSnapshot.docs) {
      const productData = { id: doc.id, ...doc.data() };

      // If a search term is provided, filter products by name or description
      if (
        searchTerm &&
        !productData.name.toLowerCase().includes(searchTerm.toLowerCase()) &&
        !productData.description.toLowerCase().includes(searchTerm.toLowerCase())
      ) {
        continue; // Skip products that don't match the search term
      }

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
    console.error("Error searching products with units:", error.message);
    res.status(500).json({
      message: "Failed to search products with units",
      error: error.message,
    });
  }
});

// New route to get products where is_seasonal == 1
router.get('/is_seasonal', async (req, res) => {  
  try {
    const snapshot = await db.collection('products').get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No products found.' });
    }

    const seasonalProducts = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((product) => product.is_seasonal === 1);

    if (seasonalProducts.length === 0) {
      return res.status(404).json({ message: 'No seasonal products found.' });
    }

    // Fetch related product units and combine data
    const productsWithDetails = [];

    for (let product of seasonalProducts) {
      const productUnitsSnapshot = await db
        .collection("product_units")
        .where("productId", "==", product.id)
        .get();

      const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

      // Fetch MRP or pricing details if needed
      const pricingSnapshot = await db
        .collection("product_pricing")
        .where("productId", "==", product.id)
        .get();

      const pricing = pricingSnapshot.docs.map((priceDoc) => priceDoc.data());

      // Combine all product details, including units and pricing
      productsWithDetails.push({
        ...product,
        productUnits,
        pricing,  // Include MRP or pricing details
      });
    }

    res.status(200).json(productsWithDetails);
  } catch (error) {
    console.error("Error fetching seasonal products:", error.message);
    res.status(500).json({
      message: "Failed to fetch seasonal products",
      error: error.message,
    });
  }
});



router.get('/is_new_launch', async (req, res) => {  
  try {
    const snapshot = await db.collection('products').get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No products found.' });
    }

    const newLaunchProducts = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((product) => product.is_new_launch === 1);

    if (newLaunchProducts.length === 0) {
      return res.status(404).json({ message: 'No new launch products found.' });
    }

    // Fetch related product units and combine data
    const productsWithDetails = [];

    for (let product of newLaunchProducts) {
      const productUnitsSnapshot = await db
        .collection("product_units")
        .where("productId", "==", product.id)
        .get();

      const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

      // Fetch MRP or pricing details if needed
      const pricingSnapshot = await db
        .collection("product_pricing")
        .where("productId", "==", product.id)
        .get();

      const pricing = pricingSnapshot.docs.map((priceDoc) => priceDoc.data());

      // Combine all product details, including units and pricing
      productsWithDetails.push({
        ...product,
        productUnits,
        pricing,  // Include MRP or pricing details
      });
    }

    res.status(200).json(productsWithDetails);
  } catch (error) {
    console.error("Error fetching new launch products:", error.message);
    res.status(500).json({
      message: "Failed to fetch new launch products",
      error: error.message,
    });
  }
});



// New route to get products where is_Recommendad == 1
router.get('/is_Recommendad', async (req, res) => {  
  try {
    const snapshot = await db.collection('products').get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No products found.' });
    }

    const recommendadProducts = snapshot.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((product) => product.is_Recommendad === 1);

    if (recommendadProducts.length === 0) {
      return res.status(404).json({ message: 'No recommended products found.' });
    }

    // Fetch related product units and combine data
    const productsWithDetails = [];

    for (let product of recommendadProducts) {
      try {
        // Fetch product units for this product
        const productUnitsSnapshot = await db
          .collection("product_units")
          .where("productId", "==", product.id)
          .get();

        const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

        // Fetch pricing details for this product
        const pricingSnapshot = await db
          .collection("product_pricing")
          .where("productId", "==", product.id)
          .get();

        const pricing = pricingSnapshot.docs.map((priceDoc) => priceDoc.data());

        // Combine all product details, including units and pricing
        productsWithDetails.push({
          ...product,
          productUnits,
          pricing,
        });

      } catch (unitPricingError) {
        console.error(`Error fetching units or pricing for product ${product.id}:`, unitPricingError.message);
        // Optionally, you can send a response even if one product fails to load units or pricing
        continue; // Skip this product and continue with others
      }
    }

    res.status(200).json(productsWithDetails);
  } catch (error) {
    console.error("Error fetching recommended products:", error.message);
    res.status(500).json({
      message: "Failed to fetch recommended products",
      error: error.message,
    });
  }
});
router.get('/previous_orders', verifyToken, async (req, res) => {  
  try {
    const userId = req.user.id; // Extract userId from the authenticated user
    
    // Query for the user's previous orders (based on 'lastUpdatedById')
    const orderDetailsSnapshot = await db.collection('order_details')
      .where('lastUpdatedById', '==', userId) // Filter by userId to get their orders
      .orderBy('last_updated_date', 'desc') // Order by the latest update date
      .limit(5) // Get only the latest 5 orders
      .get();

    if (orderDetailsSnapshot.empty) {
      return res.status(404).json({ message: 'No previous orders found.' });
    }

    // Collect all the order details into an array
    const orderDetails = orderDetailsSnapshot.docs.map((doc) => doc.data());
    const productIds = [...new Set(orderDetails.map(order => order.productId))]; // Get unique productIds

    // Fetch the corresponding products based on the productIds
    const productSnapshot = await db.collection('products')
      .where('id', 'in', productIds)
      .get();

    if (productSnapshot.empty) {
      return res.status(404).json({ message: 'No products found for the orders.' });
    }

    // Create a map of productId to product details
    const productsMap = new Map();
    productSnapshot.docs.forEach(doc => {
      const productData = doc.data();
      productsMap.set(productData.id, productData);
    });

    // Combine product details with orderDetails and fetch product units and pricing details
    const ordersWithProducts = [];

    for (const orderDetail of orderDetails) {
      const product = productsMap.get(orderDetail.productId);
      if (product) {
        // Fetch related product units
        const productUnitsSnapshot = await db
          .collection("product_units")
          .where("productId", "==", product.id)
          .get();

        const productUnits = productUnitsSnapshot.docs.map((unitDoc) => unitDoc.data());

        // Fetch pricing details for the product
        const pricingSnapshot = await db
          .collection("product_pricing")
          .where("productId", "==", product.id)
          .get();

        const pricing = pricingSnapshot.docs.map((priceDoc) => priceDoc.data());

        // Combine product details with its units and pricing
        ordersWithProducts.push({
          ...product,
          productUnits,  // Include product units
          pricing,       // Include pricing details
        });
      }
    }

    res.status(200).json(ordersWithProducts);

  } catch (error) {
    console.error("Error fetching previous orders with products:", error.message);
    res.status(500).json({
      message: "Failed to fetch previous orders with products",
      error: error.message
    });
  }
});





module.exports = router;
