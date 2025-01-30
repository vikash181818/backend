// routes/cartRoutes/cartRoutes.js

const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');

// NOTE: Make sure this path matches EXACTLY the location of
// "cartControllers.js" from above:
const {
  // transaction-based endpoints
  createOrAddToCart,
  updateCartItemQuantity,

  // minimal patch endpoint
  patchCartDetailQuantity,

  // existing endpoints
  getCartById,
  getCartDetailsByCartId,
  getUserCarts,
  getCartWithDetails,
removeCartDetail,
getTotalItemCount,
  // for BasketWidget "cart/user/cart_details_with_amount"
  getAllCartsWithDetailsForUser,
} = require('../../controllers/cartControllers/cartControllers');

// POST /api/cart/createOrAddToCart
router.post('/createOrAddToCart', verifyToken, createOrAddToCart);

// POST /api/cart/update_quantity
// => the "full recalc" approach if you still want it
router.post('/update_quantity', verifyToken, updateCartItemQuantity);

// PATCH /api/cart/detail/:cartDetailId
// => minimal approach to just patch the quantity
router.patch('/detail/:cartDetailId', verifyToken, patchCartDetailQuantity);

// GET /api/cart/:id - basic cart doc
router.get('/:id', verifyToken, getCartById);

// GET /api/cart/:cartId/details - line items only
router.get('/:cartId/details', verifyToken, getCartDetailsByCartId);

// GET /api/cart/:cartId/full-details - cart doc + product info
router.get('/:cartId/full-details', verifyToken, getCartWithDetails);

// GET /api/cart/user/all - all carts for this user (no details)
router.get('/user/all', verifyToken, getUserCarts);

// GET /api/cart/user/cart_details_with_amount
// -> returns all user's carts + details + updated totals
router.get('/user/cart_details_with_amount', verifyToken, getAllCartsWithDetailsForUser);

// NEW: DELETE /api/cart/detail/:cartDetailId
router.delete('/detail/:cartDetailId', verifyToken, removeCartDetail);

// GET /api/cart/user/total_item_count
router.get('/user/total_item_count', verifyToken, getTotalItemCount);

module.exports = router;



