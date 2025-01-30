// routes/pincode.js
const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const {
  createPincode,
  getAllPincodes,
  getPincodeById,
  updatePincode,
  deletePincode,
  getPincodesByCityId
} = require('../../controllers/addressControllers/pincodeController');

// POST /api/address/pincode
router.post('/pincode', verifyToken,createPincode);

// GET /api/address/pincode
router.get('/pincode',verifyToken, getAllPincodes);

// GET /api/address/pincode/:id
router.get('/pincode/:id',verifyToken, getPincodeById);

// PUT /api/address/pincode/:id
router.put('/pincode/:id',verifyToken, updatePincode);

// DELETE /api/address/pincode/:id
router.delete('/pincode/:id',verifyToken, deletePincode);


// New route to get pincodes by cityId 
router.get('/city/:cityId/pincodes',verifyToken, getPincodesByCityId);



module.exports = router;



