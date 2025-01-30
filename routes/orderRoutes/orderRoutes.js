// routes/orderRoutes/orderRoutes.js

const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware'); // Middleware to authenticate requests

// Import the order controllers
const {
  createOrder,
  getOrderById,
  getUserOrders,
  paytmCallback
} = require('../../controllers/orderController/orderController'); // Updated path

// Debugging: Log the imported controllers to ensure they're not undefined
console.log('Imported Controllers:', {
  createOrder,
  getOrderById,
  getUserOrders,
  paytmCallback
});

// POST /api/orders/create - Create a new order
router.post('/create', verifyToken, createOrder);

// GET /api/orders/:orderId - Get order by ID
router.get('/:orderId', verifyToken, getOrderById);

// GET /api/orders/user/all - Get all orders for the authenticated user
router.get('/user/all', verifyToken, getUserOrders);

// POST /api/orders/paytm/callback - Paytm callback route
router.post('/paytm/callback', paytmCallback);

module.exports = router;
