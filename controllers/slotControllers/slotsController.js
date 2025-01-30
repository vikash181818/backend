// controllers/addressControllers/slotsController.js

const db = require('../../config/firebase');

/**
 * @desc    Create a new slot
 * @route   POST /api/address/slots
 * @access  Protected
 */
exports.createSlot = async (req, res) => {
  console.log("req biody>>>>>>>>>>>>",req.body);
  try {
    const {
      slots,
      description,
      is_active,
      is_sameDay,
      created_date,
      last_updated_date,
      maxOrderAllowed,
    } = req.body;

    console.log("Request Body for Creating Slot:", req.body);

    // Validate required fields
    if (
      slots == null ||
      typeof slots !== 'string' ||
      slots.trim() === '' ||
      description == null ||
      typeof description !== 'string' ||
      description.trim() === '' ||
      is_active == null ||
      typeof is_active !== 'number' ||
      is_sameDay == null ||
      typeof is_sameDay !== 'number' ||
      created_date == null ||
      typeof created_date !== 'string' ||
      created_date.trim() === '' ||
      last_updated_date == null ||
      typeof last_updated_date !== 'string' ||
      last_updated_date.trim() === '' ||
      maxOrderAllowed == null ||
      typeof maxOrderAllowed !== 'number'
    ) {
      return res.status(400).json({ message: 'Missing or invalid required fields.' });
    }

    const slotData = {
      slots,
      description,
      is_active,
      is_sameDay,
      created_date,
      last_updated_date,
      maxOrderAllowed,
    };

    const docRef = await db.collection('slots').add(slotData);
    const docId = docRef.id;

    // Add the generated ID to the document
    await docRef.update({ id: docId });

    slotData.id = docId;

    return res.status(201).json({
      message: 'Slot created successfully',
      id: docId,
      data: slotData,
    });
  } catch (error) {
    console.error('Error Creating Slot:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Get all slots
 * @route   GET /api/address/slots
 * @access  Protected
 */
exports.getAllSlots = async (req, res) => {
  try {
    const snapshot = await db.collection('slots').get();
    const slots = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(slots);
  } catch (error) {
    console.error('Error Fetching Slots:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Get a slot by ID
 * @route   GET /api/address/slots/:id
 * @access  Protected
 */
exports.getSlotById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('slots').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error Fetching Slot:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Update a slot by ID
 * @route   PUT /api/address/slots/:id
 * @access  Protected
 */
exports.updateSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      slots,
      description,
      is_active,
      is_sameDay,
      created_date,
      last_updated_date,
      maxOrderAllowed,
    } = req.body;

    // Check if at least one field is provided for update
    if (
      slots === undefined &&
      description === undefined &&
      is_active === undefined &&
      is_sameDay === undefined &&
      created_date === undefined &&
      last_updated_date === undefined &&
      maxOrderAllowed === undefined
    ) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    const updateData = {};

    if (slots !== undefined) {
      if (typeof slots !== 'string' || slots.trim() === '') {
        return res.status(400).json({ message: 'Invalid slots.' });
      }
      updateData.slots = slots;
    }

    if (description !== undefined) {
      if (typeof description !== 'string' || description.trim() === '') {
        return res.status(400).json({ message: 'Invalid description.' });
      }
      updateData.description = description;
    }

    if (is_active !== undefined) {
      if (typeof is_active !== 'number') {
        return res.status(400).json({ message: 'Invalid is_active.' });
      }
      updateData.is_active = is_active;
    }

    if (is_sameDay !== undefined) {
      if (typeof is_sameDay !== 'number') {
        return res.status(400).json({ message: 'Invalid is_sameDay.' });
      }
      updateData.is_sameDay = is_sameDay;
    }

    if (created_date !== undefined) {
      if (typeof created_date !== 'string' || created_date.trim() === '') {
        return res.status(400).json({ message: 'Invalid created_date.' });
      }
      updateData.created_date = created_date;
    }

    if (last_updated_date !== undefined) {
      if (typeof last_updated_date !== 'string' || last_updated_date.trim() === '') {
        return res.status(400).json({ message: 'Invalid last_updated_date.' });
      }
      updateData.last_updated_date = last_updated_date;
    }

    if (maxOrderAllowed !== undefined) {
      if (typeof maxOrderAllowed !== 'number') {
        return res.status(400).json({ message: 'Invalid maxOrderAllowed.' });
      }
      updateData.maxOrderAllowed = maxOrderAllowed;
    }

    const docRef = db.collection('slots').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: 'Slot updated successfully' });
  } catch (error) {
    console.error('Error Updating Slot:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Delete a slot by ID
 * @route   DELETE /api/address/slots/:id
 * @access  Protected
 */
exports.deleteSlot = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('slots').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Slot not found' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'Slot deleted successfully' });
  } catch (error) {
    console.error('Error Deleting Slot:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};
