// routes/deliveryChargesRoute.js

const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const {
  createDeliveryCharge,
  getAllDeliveryCharges,
  getDeliveryChargeById,
  updateDeliveryCharge,
  deleteDeliveryCharge,
} = require('../../controllers/deliverChargesController/deliveryChargesController');

/**
 * @route   POST /api/address/deliveryCharge
 * @desc    Create a new delivery charge
 * @access  Protected
 */
router.post('/', verifyToken, createDeliveryCharge);

/**
 * @route   GET /api/address/deliveryCharge
 * @desc    Get all delivery charges
 * @access  Protected
 */
router.get('/', verifyToken, getAllDeliveryCharges);

/**
 * @route   GET /api/address/deliveryCharge/:id
 * @desc    Get a delivery charge by ID
 * @access  Protected
 */
router.get('/:id', verifyToken, getDeliveryChargeById);

/**
 * @route   PUT /api/address/deliveryCharge/:id
 * @desc    Update a delivery charge by ID
 * @access  Protected
 */
router.put('/:id', verifyToken, updateDeliveryCharge);

/**
 * @route   DELETE /api/address/deliveryCharge/:id
 * @desc    Delete a delivery charge by ID
 * @access  Protected
 */
router.delete('/:id', verifyToken, deleteDeliveryCharge);

module.exports = router;
