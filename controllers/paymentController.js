const axios = require("axios");
const https = require("https");

// Configuration
const API_KEY = "qVgkAoVPeNbIxBZXh1EMnY1D99WNKqWOa9GuPtGR0KRDxBvJ2lsWAOLz4qufQcVm";
const BASE_URL = "https://pay-gw.preprod.zeta.in/v1.0/sodexo/transactions";

// Helper Function to Generate Unique Request IDs
const generateRequestId = () => {
  return `req_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`;
};

// SSL Agent to Bypass SSL Validation
const agent = new https.Agent({
  rejectUnauthorized: false, // Disable SSL validation (temporary solution)
});

// Controller methods
exports.initiatePayment = async (req, res) => {
  const { amount } = req.body;

  console.log(req.body);

  console.log("amount>>>>>",amount);

  if (!amount || typeof amount !== "number") {
    return res.status(400).json({ error: "Amount must be a valid number" });
  }

  const requestId = generateRequestId();
  const payload = {
    requestId: requestId,
    sourceType: "CARD",
    amount: {
      currency: "INR",
      value: amount,
    },
    merchantInfo: {
      aid: "201712",
      mid: "092010001083311",
      tid: "92131296",
    },
    purposes: [
      {
        purpose: "FOOD",
        amount: {
          currency: "INR",
          value: amount,
        },
      },
    ],
    failureUrl: "http://localhost:4000/payment-failure",
    successUrl: "http://localhost:4000/payment-success",
  };

  try {
    const response = await axios.post(BASE_URL, payload, {
      headers: {
        "apiKey": API_KEY,
        "Content-Type": "application/json",
      },
      httpsAgent: agent,
    });

    const responseData = response.data;

    if (responseData.transactionState === "WAITING_FOR_SOURCE") {
      return res.status(200).json({
        message: "Transaction created successfully. Redirect user to complete the payment.",
        transactionId: responseData.transactionId,
        redirectUrl: responseData.redirectUserTo,
      });
    } else {
      return res.status(500).json({ error: "Unexpected transaction state", responseData });
    }
  } catch (error) {
    console.error("Error:", error.response?.data || error.message);
    return res.status(500).json({
      error: "Failed to initiate payment",
      details: error.response?.data || error.message,
    });
  }
};

exports.paymentSuccess = (req, res) => {
  res.send("Payment Successful!");
};

exports.paymentFailure = (req, res) => {
  const { reason, q } = req.query;
  res.send(`Payment failed. Reason: ${reason}, Query: ${q}`);
};



