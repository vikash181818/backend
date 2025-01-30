

const db = require('../../config/firebase');

/**
 * @desc    Create a new delivery charge
 * @route   POST /api/address/deliveryCharge
 * @access  Protected
 */
exports.createDeliveryCharge = async (req, res) => {
  try {
    const {
      deliveryCharge,
      minAmount,
      maxAmount,
      is_active,
      created_date,
      last_updated_date,
    } = req.body;

    console.log("Request Body for Creating Delivery Charge:", req.body);

    // Validate required fields
    if (
      deliveryCharge == null ||
      typeof deliveryCharge !== 'number' ||
      minAmount == null ||
      typeof minAmount !== 'number' ||
      maxAmount == null ||
      typeof maxAmount !== 'number' ||
      is_active == null ||
      created_date == null ||
      typeof created_date !== 'string' ||
      created_date.trim() === '' ||
      last_updated_date == null ||
      typeof last_updated_date !== 'string' ||
      last_updated_date.trim() === ''
    ) {
      return res.status(400).json({ message: 'Missing or invalid required fields.' });
    }

    const deliveryChargeData = {
      deliveryCharge,
      minAmount,
      maxAmount,
      is_active,
      created_date,
      last_updated_date,
    };

    const docRef = await db.collection('delivery_charges').add(deliveryChargeData);
    const docId = docRef.id;

    // Add the generated ID to the document
    await docRef.update({ id: docId });

    deliveryChargeData.id = docId;

    return res.status(201).json({
      message: 'Delivery charge created successfully',
      id: docId,
      data: deliveryChargeData,
    });
  } catch (error) {
    console.error('Error Creating Delivery Charge:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Get all delivery charges
 * @route   GET /api/address/deliveryCharge
 * @access  Protected
 */
exports.getAllDeliveryCharges = async (req, res) => {
  try {
    const snapshot = await db.collection('delivery_charges').get();
    const deliveryCharges = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return res.status(200).json(deliveryCharges);
  } catch (error) {
    console.error('Error Fetching Delivery Charges:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Get a delivery charge by ID
 * @route   GET /api/address/deliveryCharge/:id
 * @access  Protected
 */
exports.getDeliveryChargeById = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('delivery_charges').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Delivery charge not found' });
    }

    return res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error('Error Fetching Delivery Charge:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Update a delivery charge by ID
 * @route   PUT /api/address/deliveryCharge/:id
 * @access  Protected
 */
exports.updateDeliveryCharge = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      deliveryCharge,
      minAmount,
      maxAmount,
      is_active,
      created_date,
      last_updated_date,
    } = req.body;

    // Check if at least one field is provided for update
    if (
      deliveryCharge === undefined &&
      minAmount === undefined &&
      maxAmount === undefined &&
      is_active === undefined &&
      created_date === undefined &&
      last_updated_date === undefined
    ) {
      return res.status(400).json({ message: 'No fields to update.' });
    }

    const updateData = {};

    if (deliveryCharge !== undefined) {
      if (typeof deliveryCharge !== 'number') {
        return res.status(400).json({ message: 'Invalid deliveryCharge.' });
      }
      updateData.deliveryCharge = deliveryCharge;
    }

    if (minAmount !== undefined) {
      if (typeof minAmount !== 'number') {
        return res.status(400).json({ message: 'Invalid minAmount.' });
      }
      updateData.minAmount = minAmount;
    }

    if (maxAmount !== undefined) {
      if (typeof maxAmount !== 'number') {
        return res.status(400).json({ message: 'Invalid maxAmount.' });
      }
      updateData.maxAmount = maxAmount;
    }

    if (is_active !== undefined) {
      updateData.is_active = is_active;
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

    const docRef = db.collection('delivery_charges').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Delivery charge not found' });
    }

    await docRef.update(updateData);
    return res.status(200).json({ message: 'Delivery charge updated successfully' });
  } catch (error) {
    console.error('Error Updating Delivery Charge:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * @desc    Delete a delivery charge by ID
 * @route   DELETE /api/address/deliveryCharge/:id
 * @access  Protected
 */
exports.deleteDeliveryCharge = async (req, res) => {
  try {
    const { id } = req.params;
    const docRef = db.collection('delivery_charges').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Delivery charge not found' });
    }

    await docRef.delete();
    return res.status(200).json({ message: 'Delivery charge deleted successfully' });
  } catch (error) {
    console.error('Error Deleting Delivery Charge:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};
