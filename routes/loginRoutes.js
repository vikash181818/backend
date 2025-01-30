const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const db = require("../config/firebase"); // Import Firestore instance

const router = express.Router();

// Admin login route
router.post("/admin-login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required." });
    }

    // Query Firestore for the admin user
    const snapshot = await db.collection("users").where("email", "==", email).where("is_admin", "==", 1).get();

    if (snapshot.empty) {
      return res.status(404).json({ message: "Admin not found or invalid credentials." });
    }

    const admin = snapshot.docs[0].data();

    // Validate password
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password." });
    }

    // Generate JWT
    const token = jwt.sign(
      {
        id: snapshot.docs[0].id,
        email: admin.email,
        is_admin: admin.is_admin,
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    // Respond with token and admin details
    res.status(200).json({
      message: "Admin login successful",
      token,
      admin: {
        id: snapshot.docs[0].id,
        email: admin.email,
        first_name: admin.first_name,
        last_name: admin.last_name,
      },
    });
  } catch (error) {
    console.error("Error during admin login:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});

module.exports = router;
