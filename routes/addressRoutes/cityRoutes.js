// routes/city.js
const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const {
  createCity,
  getAllCities,
  getCityById,
  updateCity,
  deleteCity,
  getCitiesByStateId,
  getCityByCityId
} = require('../../controllers/addressControllers/cityController');


// POST /api/address/city - create a new city
router.post('/city',verifyToken, createCity);

// GET /api/address/city - get all cities
router.get('/city',verifyToken, getAllCities);

// GET /api/address/city/:id - get city by ID
router.get('/city/:id',verifyToken, getCityById);

// PUT /api/address/city/:id - update city
router.put('/city/:id',verifyToken, updateCity);

// DELETE /api/address/city/:id - delete city
router.delete('/city/:id',verifyToken, deleteCity);

// GET /api/address/city/cityId/:cityId - get city by cityId
router.get('/city/cityId/:cityId', verifyToken, getCityByCityId);



// New route to get cities by stateId 
router.get('/state/:stateId/cities',verifyToken, getCitiesByStateId);



module.exports = router;



