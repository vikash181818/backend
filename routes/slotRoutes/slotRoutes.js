// routes/slots.js

const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const {
  createSlot,
  getAllSlots,
  getSlotById,
  updateSlot,
  deleteSlot,
} = require('../../controllers/slotControllers/slotsController');

/**
 * @route   POST /api/address/slots
 * @desc    Create a new slot
 * @access  Protected
 */
router.post('/', verifyToken, createSlot);

/**
 * @route   GET /api/address/slots
 * @desc    Get all slots
 * @access  Protected
 */
router.get('/', verifyToken, getAllSlots);

/**
 * @route   GET /api/address/slots/:id
 * @desc    Get a slot by ID
 * @access  Protected
 */
router.get('/:id', verifyToken, getSlotById);

/**
 * @route   PUT /api/address/slots/:id
 * @desc    Update a slot by ID
 * @access  Protected
 */
router.put('/:id', verifyToken, updateSlot);

/**
 * @route   DELETE /api/address/slots/:id
 * @desc    Delete a slot by ID
 * @access  Protected
 */
router.delete('/:id', verifyToken, deleteSlot);

module.exports = router;
