// routes/addressCrud.js
const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const {
  createAddress,
  getAllAddresses,
  getAddressById,
  updateAddress,
  deleteAddress,
  setDefaultAddress,
  getAddressesByUserId
} = require('../../controllers/addressControllers/addressController');

// POST /api/address/addresses - create a new address
router.post('/user-addresses',verifyToken, createAddress);

// GET /api/address/addresses - get all addresses
router.get('/user-addresses',verifyToken, getAllAddresses);

// GET /api/address/addresses/:id - get address by ID
router.get('/user-addresses/:id',verifyToken, getAddressById);

// PUT /api/address/addresses/:id - update an address
router.put('/user-addresses/:id',verifyToken, updateAddress);

// DELETE /api/address/addresses/:id - delete an address
router.delete('/user-addresses/:id',verifyToken, deleteAddress);

// New PATCH route for setting the default address 
router.patch('/user-addresses/:userId/:addressId/default',verifyToken, setDefaultAddress);

// GET /api/address/addresses/user/:userId - get addresses by userId
router.get('/user-addresses/user/:userId', verifyToken, getAddressesByUserId);




module.exports = router;



