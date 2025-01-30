// controllers/addressController.js
const db = require('../../config/firebase');

// Create an Address
exports.createAddress = async (req, res) => {
    try {
        const {
            first_name,
            last_name,
            house_number,
            address,
            landmark,
            street,
            is_active,
            address_type,
            default_address,
            created_date,
            last_updated_date,
            userId,
            pincodeId,
            cityId,
            stateId,
            createdById,
            lastUpdatedById,
        } = req.body;


        console.log("req.body to add address>>>>>>>>>>>>>>", req.body);


        // Validate required fields
        if (!first_name || !last_name || !house_number || !address || is_active === undefined ||
            !address_type || default_address === undefined || !created_date || !last_updated_date ||
            !userId || !pincodeId || !cityId || !stateId || !createdById || !lastUpdatedById) {
            return res.status(400).json({ message: 'Missing required fields.' });
        }

        const addressData = {
            first_name,
            last_name,
            house_number,
            address,
            landmark: landmark || '', // If landmark is optional
            street: street || '',     // If street is optional
            is_active,
            address_type,
            default_address,
            created_date,
            last_updated_date,
            userId,
            pincodeId,
            cityId,
            stateId,
            createdById,
            lastUpdatedById,
        };

        const docRef = await db.collection('addresses').add(addressData);
        const docId = docRef.id;

        return res.status(201).json({
            message: 'Address created successfully',
            id: docId,
            data: addressData,
        });
    } catch (error) {
        console.error('Error creating address:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

// Get All Addresses
exports.getAllAddresses = async (req, res) => {
    try {
        const snapshot = await db.collection('addresses').get();
        const addresses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        return res.status(200).json(addresses);
    } catch (error) {
        console.error('Error fetching addresses:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

// Get Address by ID
exports.getAddressById = async (req, res) => {
    try {
        const { id } = req.params;
        const docRef = db.collection('addresses').doc(id);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({ message: 'Address not found' });
        }

        return res.status(200).json({ id: doc.id, ...doc.data() });
    } catch (error) {
        console.error('Error fetching address:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

// Update Address
exports.updateAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            first_name,
            last_name,
            house_number,
            address,
            landmark,
            street,
            is_active,
            address_type,
            default_address,
            created_date,
            last_updated_date,
            userId,
            pincodeId,
            cityId,
            stateId,
            createdById,
            lastUpdatedById,
        } = req.body;

        // Check if at least one field is provided for update
        if (
            first_name === undefined && last_name === undefined && house_number === undefined &&
            address === undefined && landmark === undefined && street === undefined &&
            is_active === undefined && address_type === undefined && default_address === undefined &&
            created_date === undefined && last_updated_date === undefined && userId === undefined &&
            pincodeId === undefined && cityId === undefined && stateId === undefined &&
            createdById === undefined && lastUpdatedById === undefined
        ) {
            return res.status(400).json({ message: 'No fields to update.' });
        }

        const updateData = {};
        if (first_name !== undefined) updateData.first_name = first_name;
        if (last_name !== undefined) updateData.last_name = last_name;
        if (house_number !== undefined) updateData.house_number = house_number;
        if (address !== undefined) updateData.address = address;
        if (landmark !== undefined) updateData.landmark = landmark;
        if (street !== undefined) updateData.street = street;
        if (is_active !== undefined) updateData.is_active = is_active;
        if (address_type !== undefined) updateData.address_type = address_type;
        if (default_address !== undefined) updateData.default_address = default_address;
        if (created_date !== undefined) updateData.created_date = created_date;
        if (last_updated_date !== undefined) updateData.last_updated_date = last_updated_date;
        if (userId !== undefined) updateData.userId = userId;
        if (pincodeId !== undefined) updateData.pincodeId = pincodeId;
        if (cityId !== undefined) updateData.cityId = cityId;
        if (stateId !== undefined) updateData.stateId = stateId;
        if (createdById !== undefined) updateData.createdById = createdById;
        if (lastUpdatedById !== undefined) updateData.lastUpdatedById = lastUpdatedById;

        const docRef = db.collection('addresses').doc(id);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({ message: 'Address not found' });
        }

        await docRef.update(updateData);
        return res.status(200).json({ message: 'Address updated successfully' });
    } catch (error) {
        console.error('Error updating address:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

// Delete Address
exports.deleteAddress = async (req, res) => {
    try {
        const { id } = req.params;
        const docRef = db.collection('addresses').doc(id);
        const doc = await docRef.get();

        if (!doc.exists) {
            return res.status(404).json({ message: 'Address not found' });
        }

        await docRef.delete();
        return res.status(200).json({ message: 'Address deleted successfully' });
    } catch (error) {
        console.error('Error deleting address:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};




exports.setDefaultAddress = async (req, res) => {
    try {
        const { userId, addressId } = req.params;
        // Alternatively, userId could come from an authenticated user token or req.body
        // depending on your authentication logic.

        if (!userId || !addressId) {
            return res.status(400).json({ message: 'userId and addressId are required' });
        }

        const addressesRef = db.collection('addresses');

        // 1. Get all addresses for the user
        const snapshot = await addressesRef.where('userId', '==', userId).get();
        if (snapshot.empty) {
            return res.status(404).json({ message: 'No addresses found for the given userId' });
        }

        // 2. Set default_address to 0 for all addresses of that user
        const batch = db.batch();
        snapshot.docs.forEach(doc => {
            batch.update(doc.ref, { default_address: 0 });
        });

        // 3. Set the specified address to default_address: 1
        const defaultDocRef = addressesRef.doc(addressId);
        const defaultDoc = await defaultDocRef.get();
        if (!defaultDoc.exists) {
            return res.status(404).json({ message: 'Address to set as default not found' });
        }

        batch.update(defaultDocRef, { default_address: 1 });

        await batch.commit();

        return res.status(200).json({ message: 'Default address updated successfully' });
    } catch (error) {
        console.error('Error setting default address:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};


// Get Addresses by User ID
exports.getAddressesByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        if (!userId) {
            return res.status(400).json({ message: 'userId is required' });
        }

        const snapshot = await db.collection('addresses').where('userId', '==', userId).get();

        if (snapshot.empty) {
            return res.status(404).json({ message: 'No addresses found for the given userId' });
        }

        const addresses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

        return res.status(200).json(addresses);
    } catch (error) {
        console.error('Error fetching addresses by userId:', error.message);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};


