// routes/addressRoutes.js
const express = require('express');
const router = express.Router();
const verifyToken = require('../../middleware/authMiddleware');
const { createState,getAllStates,getStateById,updateState,deleteState, } = require('../../controllers/addressControllers/stateController');

// POST /api/address/state - create a new state document
router.post('/state',verifyToken, createState);
router.get('/state',verifyToken,getAllStates);
router.get('/state/:id',verifyToken, getStateById);
router.put('/state/:id',verifyToken, updateState);
router.delete('/state/:id',verifyToken, deleteState);



module.exports = router;



