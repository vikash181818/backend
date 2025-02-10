const express = require("express");
const dotenv = require("dotenv");
const bcrypt = require("bcrypt");
const db = require("./config/firebase"); // Import Firestore instance
const loginRoutes = require("./routes/loginRoutes"); // Import login routes
const userLoginAndSignup=require("./routes/userLoginAndSignup");
const unitRoutes = require("./routes/unitRoutes"); // Import unit routes
const categoryRoutes = require('./routes/categoryRoutes');
const productRoutes = require('./routes/productRoutes');
const productUnitRoutes=require('./routes/productUnitRoutes');
const productWithUnitsRoutes=require('./routes/productWithUnitsRoutes');
const stateRoutes=require('./routes/addressRoutes/stateRoutes');
const cityRoutes=require('./routes/addressRoutes/cityRoutes');
const pincodeRoutes=require('./routes/addressRoutes/pincodeRoutes');
const addressRoutes=require('./routes/addressRoutes/addressRoutes');
const carouselRoutes=require('./routes/carouselRoutes/carouselRoutes');
const deliveryChargesRoute=require('./routes/deliveryCharges/deliveryChargesRoute');
const paymentRoutes=require('./routes/paymentRoutes');

const slotRoutes=require('./routes/slotRoutes/slotRoutes')

const cartRoutes=require("./routes/cartRoutes/cartRoutes");

const filterRoutes=require('./routes/filterRoutes');

const userProfileRoute=require('./routes/userProfileRoute');

const orderRoutes=require('./routes/orderRoutes/orderRoutes');
const reset=require('./routes/resetRoute')
// Load environment variables
dotenv.config();

// Create an Express app
const app = express();

// Middleware to parse JSON
app.use(express.json());
const cors = require('cors'); 
app.use(cors());



// Serve static files from the "assets" directory
app.use('/assets', express.static('assets'));
app.use("/api/",reset)
// Use login routes
app.use("/api/", loginRoutes,carouselRoutes); 

app.use("/api/user",userLoginAndSignup,userProfileRoute);

app.use("/api/manageProducts", unitRoutes, categoryRoutes, productRoutes,productUnitRoutes,productWithUnitsRoutes);

app.use("/api/manageProducts", unitRoutes, categoryRoutes, productRoutes,productUnitRoutes,productWithUnitsRoutes,filterRoutes);

app.use('/api/address', stateRoutes,cityRoutes,pincodeRoutes,addressRoutes);

app.use('/api/deliveryCharges',deliveryChargesRoute);

app.use('/api/slots',slotRoutes);



app.use("/api/cart",cartRoutes);

app.use('/api/orders',orderRoutes);
app.use("/", paymentRoutes);

// Root route to test the server
app.get("/", (req, res) => {
  res.send("Server running on port 3000. Firebase connected successfully!");
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});
