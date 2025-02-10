const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const db = require("../config/firebase");
const router = express.Router();

// Create transporter for email service
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "kumarsharmavikash185@gmail.com", // Replace with your email
    pass: "zuym bloq rypx zipq", // Use an app password (not your direct email password)
  },
});

// Forgot Password API
router.post("/forgot-password", async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ message: "Email and new password are required." });
    }

    // Check if user exists
    const usersCollection = db.collection("users");
    const userSnapshot = await usersCollection.where("email", "==", email).get();
    if (userSnapshot.empty) {
      return res.status(404).json({ message: "User not found." });
    }

    const userDoc = userSnapshot.docs[0];
    const userId = userDoc.id;

    // Generate a reset token
    const resetToken = jwt.sign(
      { userId, newPassword },
      process.env.JWT_SECRET,
      { expiresIn: "15m" } // Token valid for 15 minutes
    );

    // Construct the reset link
    const resetLink = `http://98.70.35.28:3000/api/reset-password/${resetToken}`;
    console.log("Reset Password Link:", resetLink);

    // Send email with reset link
    const mailOptions = {
      from: "kumarsharmavikash185@gmail.com",
      to: email,
      subject: "Password Reset Request",
      text: `You requested a password reset. Click the link below to reset your password:
      ${resetLink}
      
      If you did not request this, please ignore this email.`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({
      message: "Password reset link has been sent to your email.",
    });
  } catch (error) {
    console.error("Error in forgot password:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});

// Reset Password API
router.get("/reset-password/:token", async (req, res) => {
  try {
    const { token } = req.params;

    if (!token) {
      return res.status(400).send("<h1>Token is required.</h1>");
    }

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      return res.status(400).send("<h1>Invalid or expired token.</h1>");
    }

    const { userId, newPassword } = decoded;

    if (!newPassword) {
      return res.status(400).send("<h1>New password is required.</h1>");
    }

    const userRef = db.collection("users").doc(userId);
    const userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      return res.status(404).send("<h1>User not found.</h1>");
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in Firestore
    await userRef.update({ password: hashedPassword, last_updated_date: new Date().toISOString() });

    // Send success HTML message
    res.status(200).send("<h1>Password has been reset successfully. Please login with your new password.</h1>");
  } catch (error) {
    console.error("Error in resetting password:", error.message);
    res.status(500).send("<h1>Internal server error</h1>");
  }
});


module.exports = router;
