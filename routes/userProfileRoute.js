const express = require("express");
const db = require("../config/firebase"); // Firestore instance
const router = express.Router();
const verifyToken=require('../middleware/authMiddleware');


// Get User Profile Route
router.get("/:id",verifyToken, async (req, res) => {
  try {
    const { id } = req.params;


    // Validate input
    if (!id) {
      return res.status(400).json({ message: "User ID is required." });
    }


    // Fetch user document from Firestore
    const userDoc = await db.collection("users").doc(id).get();


    if (!userDoc.exists) {
      return res.status(404).json({ message: "User not found." });
    }


    // Extract user data, excluding sensitive information
    const userData = userDoc.data();
    const userProfile = {
      id: userDoc.id,
      first_name: userData.first_name,
      last_name: userData.last_name,
      phone: userData.phone,
      email: userData.email,
      ref_code: userData.ref_code,
      is_admin: userData.is_admin,
      is_active: userData.is_active,
      is_staff: userData.is_staff,
      is_cod_active: userData.is_cod_active,
      created_date: userData.created_date,
      last_updated_date: userData.last_updated_date,
    };


    // Respond with the user profile
    res.status(200).json({ message: "User profile retrieved successfully.", user: userProfile });
  } catch (error) {
    console.error("Error fetching user profile:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});


module.exports = router;





