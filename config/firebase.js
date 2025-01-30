const admin = require("firebase-admin");
const dotenv = require("dotenv");

// Load environment variables
dotenv.config();

// Debugging
console.log("GOOGLE_APPLICATION_CREDENTIALS:", process.env.GOOGLE_APPLICATION_CREDENTIALS);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(require(process.env.GOOGLE_APPLICATION_CREDENTIALS)),
    projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  });
}

const db = admin.firestore();
module.exports = db;