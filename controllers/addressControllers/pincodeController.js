// controllers/pincodeController.js
const db  = require('../../config/firebase');

// Create a Pincode
exports.createPincode = async (req, res) => {
  try {
    const {
      pincode,
      post_office,
      is_active,
      created_date,
      last_updated_date,
      cityId,
      createdById,
      lastUpdatedById,
    } = req.body;

    // Validate required fields
    if (!pincode || !post_office || is_active === undefined || !created_date || !last_updated_date || !cityId || !createdById || !lastUpdatedById) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }

    const pincodeData = {
      pincode,
      post_office,
      is_active,
      created_date,
      last_updated_date,
      cityId,
      createdById,
      lastUpdatedById,
    };

    const docRef = await db.collection('pincodes').add(pincodeData);
    const docId = docRef.id;

    return res.status(201).json({
      message: 'Pincode created successfully',
      id: docId,
      data: pincodeData,
    });
  } catch (error) {
    console.error('Error creating pincode:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get All Pincodes
exports.getAllPincodes = async (req, res) => {
  try {
    const snapshot = await db.collection('pincodes').get();
    const pincodes = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(pincodes);
  } catch (error) {
    console.error('Error fetching pincodes:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get Pincode by ID
exports.getPincodeById = async (req, res) => {
  try {


    
    const { id } = req.params;
    const docRef = db.collection('pincodes').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Pincode not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error fetching pincode:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Update Pincode
exports.updatePincode = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      pincode,
      post_office,
      is_active,
      created_date,
      last_updated_date,
      cityId,
      createdById,
      lastUpdatedById,
    } = req.body;

    // Check if at least one field is provided to update
    if (
      pincode === undefined && post_office === undefined && is_active === undefined &&
      created_date === undefined && last_updated_date === undefined && cityId === undefined &&
      createdById === undefined && lastUpdatedById === undefined
    ) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    const updateData = {};
    if (pincode !== undefined) updateData.pincode = pincode;
    if (post_office !== undefined) updateData.post_office = post_office;
    if (is_active !== undefined) updateData.is_active = is_active;
    if (created_date !== undefined) updateData.created_date = created_date;
    if (last_updated_date !== undefined) updateData.last_updated_date = last_updated_date;
    if (cityId !== undefined) updateData.cityId = cityId;
    if (createdById !== undefined) updateData.createdById = createdById;
    if (lastUpdatedById !== undefined) updateData.lastUpdatedById = lastUpdatedById;

    const docRef = db.collection('pincodes').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Pincode not found' });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: 'Pincode updated successfully' });
  } catch (error) {
    console.error('Error updating pincode:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Delete Pincode
exports.deletePincode = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('pincodes').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Pincode not found' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'Pincode deleted successfully' });
  } catch (error) {
    console.error('Error deleting pincode:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};



exports.getPincodesByCityId = async (req, res) => {
  try {
    const { cityId } = req.params;

    if (!cityId) {
      return res.status(400).json({ message: 'cityId is required' });
    }

    const snapshot = await db.collection('pincodes').where('cityId', '==', cityId).get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No pincodes found for the given cityId' });
    }

    const pincodes = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(pincodes);
  } catch (error) {
    console.error('Error fetching pincodes by cityId:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};





