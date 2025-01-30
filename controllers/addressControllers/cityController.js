// controllers/cityController.js
const db = require('../../config/firebase');

// Create City
exports.createCity = async (req, res) => {
  try {
    const {
      city,
      is_active,
      created_date,
      last_updated_date,
      stateId,
      createdById,
      lastUpdatedById,
    } = req.body;

    console.log("req.body to add city>>>>>>>>>>>>>", req.body);

    // Example: Best practice is to check each field carefully
    if (
      city == null || typeof city !== 'string' || city.trim() === '' ||
      is_active == null ||
      created_date == null || typeof created_date !== 'string' || created_date.trim() === '' ||
      last_updated_date == null || typeof last_updated_date !== 'string' || last_updated_date.trim() === '' ||
      stateId == null || typeof stateId !== 'string' || stateId.trim() === '' ||
      createdById == null ||
      lastUpdatedById == null
    ) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }

    const cityData = {
      city,
      is_active,
      created_date,
      last_updated_date,
      stateId,
      createdById,
      lastUpdatedById,
    };

    const docRef = await db.collection('cities').add(cityData);
    const docId = docRef.id;

    // Update cityData with the id field
    cityData.id = docId;
    await docRef.update({ id: docId });

    return res.status(201).json({
      message: 'City created successfully',
      id: docId,
      data: cityData,
    });
  } catch (error) {
    console.error('Error creating city:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get All Cities
exports.getAllCities = async (req, res) => {
  try {
    const snapshot = await db.collection('cities').get();
    const cities = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(cities);
  } catch (error) {
    console.error('Error fetching cities:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get City by ID
exports.getCityById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('cities').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'City not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error fetching city:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Update City
exports.updateCity = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      city,
      is_active,
      created_date,
      last_updated_date,
      stateId,
      createdById,
      lastUpdatedById,
    } = req.body;

    if (
      city === undefined &&
      is_active === undefined &&
      created_date === undefined &&
      last_updated_date === undefined &&
      stateId === undefined &&
      createdById === undefined &&
      lastUpdatedById === undefined
    ) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    const updateData = {};
    if (city !== undefined) updateData.city = city;
    if (is_active !== undefined) updateData.is_active = is_active;
    if (created_date !== undefined) updateData.created_date = created_date;
    if (last_updated_date !== undefined) updateData.last_updated_date = last_updated_date;
    if (stateId !== undefined) updateData.stateId = stateId;
    if (createdById !== undefined) updateData.createdById = createdById;
    if (lastUpdatedById !== undefined) updateData.lastUpdatedById = lastUpdatedById;

    const docRef = db.collection('cities').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'City not found' });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: 'City updated successfully' });
  } catch (error) {
    console.error('Error updating city:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Delete City
exports.deleteCity = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('cities').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'City not found' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'City deleted successfully' });
  } catch (error) {
    console.error('Error deleting city:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get City by cityId
exports.getCityByCityId = async (req, res) => {
  try {
    const { cityId } = req.params;

    console.log("city Id received>>************", cityId);

    if (!cityId) {
      return res.status(400).json({ message: 'cityId is required' });
    }

    const snapshot = await db.collection('cities').where('id', '==', cityId).get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'City not found for the given cityId' });
    }

    const city = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))[0];
    return res.status(200).json(city);
  } catch (error) {
    console.error('Error fetching city by cityId:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

// Get Cities by State ID
exports.getCitiesByStateId = async (req, res) => {
  try {
    const { stateId } = req.params;

    if (!stateId) {
      return res.status(400).json({ message: 'stateId is required' });
    }

    const snapshot = await db.collection('cities').where('stateId', '==', stateId).get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No cities found for the given stateId' });
    }

    const cities = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(cities);
  } catch (error) {
    console.error('Error fetching cities by stateId:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};