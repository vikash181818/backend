const express = require("express");
const verifyToken = require("../middleware/authMiddleware");
const db = require("../config/firebase");

const router = express.Router();

// Create a new unit
router.post("/units", verifyToken, async (req, res) => {
  try {
    const { unit_code, unit_name, is_active = 1 } = req.body;

    if (!unit_code || !unit_name) {
      return res.status(400).json({ message: "unit_code and unit_name are required." });
    }

    const unitData = {
      id: Date.now().toString(),
      unit_code,
      unit_name,
      is_active,
      created_date: new Date().toISOString(),
      last_updated_date: new Date().toISOString(),
      createdById: req.user.id,
      lastUpdatedById: req.user.id,
    };

    await db.collection("units").doc(unitData.id).set(unitData);

    res.status(201).json({
      message: "Unit created successfully!",
      unit: unitData,
    });
  } catch (error) {
    console.error("Error creating unit:", error.message);
    res.status(500).json({ message: "Failed to create unit", error: error.message });
  }
});

// Edit an existing unit
router.patch("/units/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    if (!id) {
      return res.status(400).json({ message: "Unit ID is required." });
    }

    const docRef = db.collection("units").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Unit not found." });
    }

    await docRef.update({
      ...updates,
      last_updated_date: new Date().toISOString(),
      lastUpdatedById: req.user.id,
    });

    res.status(200).json({ message: "Unit updated successfully!" });
  } catch (error) {
    console.error("Error updating unit:", error.message);
    res.status(500).json({ message: "Failed to update unit", error: error.message });
  }
});

// Get all units
router.get("/units", verifyToken, async (req, res) => {
  try {
    const snapshot = await db.collection("units").get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "No units found." });
    }

    const units = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(units);
  } catch (error) {
    console.error("Error fetching units:", error.message);
    res.status(500).json({ message: "Failed to fetch units", error: error.message });
  }
});

// Get a specific unit by ID
router.get("/units/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Unit ID is required." });
    }

    const docRef = db.collection("units").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Unit not found." });
    }

    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    console.error("Error fetching unit:", error.message);
    res.status(500).json({ message: "Failed to fetch unit", error: error.message });
  }
});

// Delete a specific unit by ID
router.delete("/units/:id", verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({ message: "Unit ID is required." });
    }

    const docRef = db.collection("units").doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Unit not found." });
    }

    await docRef.delete();

    res.status(200).json({ message: "Unit deleted successfully!" });
  } catch (error) {
    console.error("Error deleting unit:", error.message);
    res.status(500).json({ message: "Failed to delete unit", error: error.message });
  }
});

module.exports = router;
