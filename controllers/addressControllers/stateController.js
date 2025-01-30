// controllers/stateController.js
const  db  = require('../../config/firebase');

exports.createState = async (req, res) => {
  console.log("req.body>>>>>>>>>>>>", req.body);
  try {
    const {
      state,
      is_active,
      created_date,
      last_updated_date,
      createdById,
      lastUpdatedById,
    } = req.body;

   // Validate required fields for State
if (
  // state must be a non-empty string
  state == null ||
  typeof state !== 'string' ||
  state.trim() === '' ||

  // is_active must exist (0 or 1)
  is_active == null ||
  (is_active !== 0 && is_active !== 1) ||

  // created_date must be a non-empty string
  created_date == null ||
  typeof created_date !== 'string' ||
  created_date.trim() === '' ||

  // last_updated_date must be a non-empty string
  last_updated_date == null ||
  typeof last_updated_date !== 'string' ||
  last_updated_date.trim() === '' ||

  // createdById must be provided (not null/undefined)
  createdById == null ||

  // lastUpdatedById must be provided (not null/undefined)
  lastUpdatedById == null
) {
  return res.status(400).json({ message: 'Missing or invalid required fields.' });
}


    const stateData = {
      state,
      is_active,
      created_date,
      last_updated_date,
      createdById,
      lastUpdatedById,
    };

    const docRef = await db.collection('states').add(stateData);
    const docId = docRef.id;

    return res.status(201).json({
      message: 'State created successfully',
      id: docId,
      data: stateData,
    });
  } catch (error) {
    console.error('Error creating state:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};


exports.getAllStates = async (req, res) => {
  try {
    const snapshot = await db.collection('states').get();
    const states = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(states);
  } catch (error) {
    console.error('Error fetching states:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};


exports.getStateById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('states').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'State not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error fetching state:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};


exports.updateState = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      state,
      is_active,
      created_date,
      last_updated_date,
      createdById,
      lastUpdatedById,
    } = req.body;

    // At minimum, require at least one field to update (or handle partial updates)
    if (!state && !is_active && !created_date && !last_updated_date && !createdById && !lastUpdatedById) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    const updateData = {};
    if (state !== undefined) updateData.state = state;
    if (is_active !== undefined) updateData.is_active = is_active;
    if (created_date !== undefined) updateData.created_date = created_date;
    if (last_updated_date !== undefined) updateData.last_updated_date = last_updated_date;
    if (createdById !== undefined) updateData.createdById = createdById;
    if (lastUpdatedById !== undefined) updateData.lastUpdatedById = lastUpdatedById;

    const docRef = db.collection('states').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'State not found' });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: 'State updated successfully' });
  } catch (error) {
    console.error('Error updating state:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};



exports.deleteState = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('states').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'State not found' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'State deleted successfully' });
  } catch (error) {
    console.error('Error deleting state:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};



















