const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer"); // To send email
const db = require("../config/firebase"); // Firestore instance
const router = express.Router();

// Create a transporter for email verification
const transporter = nodemailer.createTransport({
  service: "gmail",
  logger: true,
  debug: true,
  auth: {
    user: "kumarsharmavikash185@gmail.com", // Replace with your email
    pass: "zuym bloq rypx zipq",            // Replace with your email password or app password
  },
});

// Unified route for signup (handles both POST for signup and GET for email verification)
router
  .route("/signup")
  // GET handler for email verification
  .get(async (req, res) => {
    try {
      const { token } = req.query;
      if (!token) {
        return res.status(400).send("Verification token missing.");
      }

      let decoded;
      try {
        // Verify the token using JWT secret
        decoded = jwt.verify(token, process.env.JWT_SECRET);
      } catch (error) {
        console.error("Token verification error:", error);
        return res.status(400).send("Invalid or expired token.");
      }

      const userId = decoded.userId; // Extracted from signup token payload
      const userRef = db.collection("users").doc(userId);
      const userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        return res.status(404).send("User not found.");
      }

      // Update the user's active status to verified using set with merge
      await userRef.set({ is_active: 1 }, { merge: true });

      // Optional: Confirm the update by reading the user data
      const updatedUser = await userRef.get();
      console.log("User after verification:", updatedUser.data());

      res.status(200).send("Email verified successfully. You can now log in.");
    } catch (error) {
      console.error("Error during email verification:", error.message);
      res.status(500).send("Internal server error.");
    }
  })
  // POST handler for user signup
  .post(async (req, res) => {
    try {
      const { firstname, lastname, mobile, email, referenceCode, password } = req.body;

      // Validate input
      if (!firstname || !lastname || !mobile || !email || !referenceCode || !password) {
        return res.status(400).json({ message: "All fields are required." });
      }

      // Check if user already exists by email
      let userSnapshot = await db.collection("users").where("email", "==", email).get();
      if (!userSnapshot.empty) {
        return res.status(400).json({ message: "Email already in use." });
      }

      // Check if user already exists by mobile
      userSnapshot = await db.collection("users").where("phone", "==", mobile).get();
      if (!userSnapshot.empty) {
        return res.status(400).json({ message: "Mobile number already in use." });
      }

      // Hash the password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user object with is_active set to 0 (unverified)
      const newUser = {
        first_name: firstname,
        last_name: lastname,
        phone: mobile,
        email,
        ref_code: referenceCode,
        password: hashedPassword,
        is_admin: 0,
        is_active: 0,  // Mark user as unverified initially
        created_date: new Date().toISOString(),
        last_updated_date: new Date().toISOString(),
      };

      // Add user to Firestore and get document reference
      const userRef = await db.collection("users").add(newUser);

      // Update the user document to include Firestore document ID
      await userRef.update({ id: userRef.id });

      // Generate a verification token
      const verificationToken = jwt.sign(
        { userId: userRef.id },
        process.env.JWT_SECRET,
        { expiresIn: "1h" }
      );

      // Use localhost domain for testing - adjust as necessary for production
      const verificationLink = `http://192.168.68.122:3000/api/user/signup?token=${verificationToken}`;

      // Set up the email
      const mailOptions = {
        from: "onlinedukaans@gmail.com",
        to: email,
        subject: "Email Verification",
        text: `Please verify your email by clicking on the following link: ${verificationLink}`,
      };

      // Send the verification email
      await transporter.sendMail(mailOptions);

      // Respond to the client
      res.status(201).json({
        message: "User created successfully. Please check your email for verification.",
      });
    } catch (error) {
      console.error("Error during user signup:", error.message);
      res.status(500).json({ message: "Internal server error", error: error.message });
    }
  });

// User Login Route (with email or mobile)
router.post("/user-login", async (req, res) => {
  try {
    const { login, password } = req.body;

    // Check if email/mobile and password are provided in the request body
    if (!login || !password) {
      return res.status(400).json({ message: "Login (email/mobile) and password are required." });
    }

    const usersCollection = db.collection("users");

    // First, try to find the user by email
    let snapshot = await usersCollection.where("email", "==", login).get();

    // If no user found by email, try the mobile number
    if (snapshot.empty) {
      const phoneNumber = login.toString();
      snapshot = await usersCollection.where("phone", "==", phoneNumber).get();
      if (snapshot.empty) {
        return res.status(404).json({ message: "User not found or invalid credentials." });
      }
    }

    // Get the user data from Firestore
    const userDoc = snapshot.docs[0];
    const user = userDoc.data();

    // Check if the user's email is verified (is_active should be 1)
    if (user.is_active === 0) {
      return res.status(400).json({ message: "Email not verified. Please verify your email." });
    }

    // Validate the password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid login or password." });
    }

    // Generate JWT token with user details
    const token = jwt.sign(
      {
        id: userDoc.id,
        email: user.email,
        phone: user.phone,
        is_admin: user.is_admin,
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    // Respond with the JWT token and user details
    res.status(200).json({
      message: "User login successful",
      token,
      user: {
        id: userDoc.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        phone: user.phone,
        ref_code: user.ref_code,
      },
    });
  } catch (error) {
    console.error("Error during user login:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});

// Forgot Password Route
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required." });
    }

    const userSnapshot = await db.collection("users").where("email", "==", email).get();
    if (userSnapshot.empty) {
      return res.status(404).json({ message: "User not found." });
    }

    // Generate reset token
    const resetToken = jwt.sign({ id: userSnapshot.docs[0].id }, process.env.JWT_SECRET, {
      expiresIn: "1h", // Token expires in 1 hour
    });

    // Create reset link with token
    const resetLink = `http://192.168.68.125:3000/api/user/reset-password?token=${resetToken}`;

    // Set up email content with the reset link
    const mailOptions = {
      from: "kumarsharmavikash185@gmail.com",
      to: email,
      subject: "Password Reset Request",
      text: `You requested a password reset. Please click the following link to reset your password: ${resetLink}`,
    };

    // Send the email
    await transporter.sendMail(mailOptions);

    res.status(200).json({ message: "Password reset link sent to email." });
  } catch (error) {
    console.error("Error during forgot password:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});

// Reset Password Route
router.post("/reset-password", async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({ message: "Token and new password are required." });
    }

    let decoded;
    try {
      // Verify token
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      return res.status(400).json({ message: "Invalid or expired token." });
    }

    const userId = decoded.id;  // Extract user ID from token

    // Fetch user from Firestore using the userId
    const userSnapshot = await db.collection("users").doc(userId).get();
    if (!userSnapshot.exists) {
      return res.status(404).json({ message: "User not found." });
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update the user's password in Firestore
    await db.collection("users").doc(userId).update({ password: hashedPassword });

    res.status(200).json({ message: "Password has been reset successfully." });
  } catch (error) {
    console.error("Error during reset password:", error.message);
    res.status(500).json({ message: "Internal server error", error: error.message });
  }
});

module.exports = router;
