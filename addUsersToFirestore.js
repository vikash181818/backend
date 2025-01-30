// const admin = require("firebase-admin");
// const bcrypt = require("bcrypt");
// const serviceAccount = require("./config/serviceAccountKey.json");

// // Initialize Firebase Admin SDK
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

// const db = admin.firestore();

// // Function to hash the password
// async function hashPassword(password) {
//   const saltRounds = 10; // Number of salt rounds
//   return await bcrypt.hash(password, saltRounds);
// }

// // Function to add users to Firestore
// async function addUsers() {
//   try {
//     // Define the user data to add
//     const users = [
//       {
//         id: "1",
//         phone: "9606762961",
//         email: "admin@drighna.com",
//         password: "Drighna@2024", // Plain-text password
//         otp: null,
//         first_name: "Drighna",
//         last_name: "Tech",
//         is_active: 1,
//         is_staff: 1,
//         is_admin: 1,
//         created_date: new Date(),
//         last_updated_date: new Date(),
//         ref_code: null,
//         my_code: "WEL501",
//         wallet_balance: 0,
//         user_type: null,
//         soxexo_sourceId: null,
//         is_cod_active: 1,
//       },
//     ];

//     // Iterate through the users array
//     for (const user of users) {
//       // Hash the password before storing it
//       user.password = await hashPassword(user.password);

//       // Reference to the Firestore document
//       const userRef = db.collection("users").doc(user.id);

//       // Add the user to Firestore
//       await userRef.set(user);
//       console.log(`User with ID ${user.id} added successfully`);
//     }

//     console.log("All users added successfully!");
//   } catch (error) {
//     console.error("Error adding users:", error);
//   }
// }

// // Execute the function
// addUsers();
