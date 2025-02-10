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

      // Make sure this is your actual domain for production (adjust for your environment)
      const verificationLink = `http://192.168.68.116:3000/api/user/signup?token=${verificationToken}`;
      console.log("Verification link:", verificationLink); // Debugging line to ensure the link is correct

      // Set up the email with HTML content
      const mailOptions = {
        from: "kumarsharmavikash185@gmail.com", // Change this to your email
        to: email,
        subject: "Welcome to Our Service - Email Verification",
        html: `
          <html>
            <head>
              <style>
                body {
                  font-family: Arial, sans-serif;
                  background-color: #f4f4f4;
                  color: #333;
                  padding: 20px;
                }
                .container {
                  max-width: 600px;
                  margin: auto;
                  background-color: #ffffff;
                  padding: 30px;
                  border-radius: 8px;
                  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }
                .header {
                  text-align: center;
                  padding-bottom: 20px;
                }
                .header h1 {
                  font-size: 24px;
                  color: #4CAF50;
                }
                .button {
                  display: block;
                  width: 100%;
                  background-color: #4CAF50;
                  color: white;
                  padding: 15px;
                  text-align: center;
                  text-decoration: none;
                  font-size: 16px;
                  border-radius: 5px;
                  margin-top: 20px;
                }
                .footer {
                  font-size: 12px;
                  color: #777;
                  text-align: center;
                  margin-top: 40px;
                }
              </style>
            </head>
            <body>
              <div class="container">
                <div class="header">
                  <h1>Welcome to Our Service!</h1>
                  <p>We are excited to have you on board. Please confirm your email address to get started.</p>
                </div>
                <p>To verify your email address and activate your account, please click the button below:</p>
                <a href="${verificationLink}" class="button">Verify Email</a>
                <div class="footer">
                  <p>If you did not sign up for our service, you can safely ignore this email.</p>
                  <p>Thank you for joining!</p>
                </div>
              </div>
            </body>
          </html>
        `,
      };

      // Send the verification email
      await transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
          console.error("Error sending email:", error);
          return res.status(500).json({ message: "Error sending verification email." });
        } else {
          console.log("Verification email sent:", info.response); // Debugging line to ensure email is sent
        }
      });

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
  console.log("req.body>>>>>>>>>>>>>>>>>>>>>>>>>>>", req.body);
  try {
    const { login, password } = req.body;

    console.log("req.body>>>>>>>>>>>>", req.body);
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




module.exports = router;
