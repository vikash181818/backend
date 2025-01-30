const express = require("express");
const paymentController = require("../controllers/paymentController");

const router = express.Router();

// Define routes and link them to controller methods
router.post("/initiate-payment", paymentController.initiatePayment);
router.get("/payment-success", paymentController.paymentSuccess);
router.get("/payment-failure", paymentController.paymentFailure);

module.exports = router;



