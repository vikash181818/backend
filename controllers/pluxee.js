const express = require("express");
const axios = require("axios");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for parsing JSON requests
app.use(express.json());

// Base URL and API key for Pluxee (Sodexo)
const PLUXEE_BASE_URL = "https://pay-gw.preprod.zeta.in";
const PLUXEE_API_KEY = process.env.PLUXEE_API_KEY || "qVgkAoVPeNbIxBZXh1EMnY1D99WNKqWOa9GuPtGR0KRDxBvJ2lsWAOLz4qufQcVm";

// In-memory storage for transactions
const transactions = [];

// Create Payment (POST /api/payments)
app.post("/api/payments", async (req, res) => {
  try {
    const {
      cardNumber,
      validThru,
      cvv,
      pin,
      amount,
      merchantId,
      terminalId,
    } = req.body;

    // Validate request data
    if (!cardNumber || !validThru || !cvv || !pin || !amount || !merchantId || !terminalId) {
      return res.status(400).json({ error: "All fields are required." });
    }

    const payload = {
      cardNumber,
      validThru,
      cvv,
      pin,
      amount,
      merchantId,
      terminalId,
    };

    // Send request to Pluxee API
    const response = await axios.post(PLUXEE_BASE_URL, payload, {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${PLUXEE_API_KEY}`,
      },
    });

    // Store transaction in memory
    const transaction = {
      id: transactions.length + 1,
      ...payload,
      status: response.data.status,
      response: response.data,
    };
    transactions.push(transaction);

    res.status(201).json({ message: "Payment successful", transaction });
  } catch (error) {
    console.error("Error creating payment:", error.message);
    res.status(500).json({ error: "Payment failed", details: error.message });
  }
});

// Read All Transactions (GET /api/payments)
app.get("/api/payments", (req, res) => {
  res.status(200).json(transactions);
});

// Read Single Transaction (GET /api/payments/:id)
app.get("/api/payments/:id", (req, res) => {
  const transaction = transactions.find((t) => t.id === parseInt(req.params.id));
  if (!transaction) {
    return res.status(404).json({ error: "Transaction not found." });
  }
  res.status(200).json(transaction);
});

// Update Transaction (PUT /api/payments/:id)
app.put("/api/payments/:id", (req, res) => {
  const transaction = transactions.find((t) => t.id === parseInt(req.params.id));
  if (!transaction) {
    return res.status(404).json({ error: "Transaction not found." });
  }

  const { status } = req.body;
  if (!status) {
    return res.status(400).json({ error: "Status is required." });
  }

  transaction.status = status;
  res.status(200).json({ message: "Transaction updated successfully", transaction });
});

// Delete Transaction (DELETE /api/payments/:id)
app.delete("/api/payments/:id", (req, res) => {
  const index = transactions.findIndex((t) => t.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: "Transaction not found." });
  }

  transactions.splice(index, 1);
  res.status(200).json({ message: "Transaction deleted successfully." });
});

// Start Server
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
