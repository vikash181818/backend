// controllers/orderControllers/orderControllers.js

const { v4: uuidv4 } = require('uuid'); // For generating unique order IDs
const PaytmChecksum = require('paytmchecksum'); // Paytm checksum utility
const paytmConfig = require('../../config/paytm'); // Paytm configuration
const axios = require('axios'); // For making HTTP requests
const db = require('../../config/firebase'); // Firestore instance
const qs = require('qs'); // For query string parsing

/**
 * Helper Function to Ensure All Values Are Strings
 * Converts all values in an object to strings to prevent errors in PaytmChecksum
 */
const stringifyParams = (params) => {
  const stringified = {};
  for (const key in params) {
    if (params.hasOwnProperty(key)) {
      stringified[key] = params[key] !== undefined && params[key] !== null ? String(params[key]) : '';
    }
  }
  return stringified;
};

/**
 * Create a new order
 * POST /api/orders/create
 * For Paytm payments, it initiates the transaction and returns the txnToken
 * For other payments, it creates the order immediately
 */
exports.createOrder = async (req, res) => {
  const {
    cartId,
    deliveryDate,
    selectedSlotId,
    paymentMethod,
    deliveryCharge,
    shippingAddressId,
    paymentIntendId
  } = req.body;

  const userId = req.user.id;

  try {
    console.log(req.body)
    // Validate required fields
    if (!cartId || !deliveryDate || !selectedSlotId || !paymentMethod || deliveryCharge ==null || !shippingAddressId) {
      return res.status(400).json({ message: 'Missing required fields.' });
    }

    // Fetch cart details
    const cartDetailsSnapshot = await db
      .collection('cart_details')
      .where('cartId', '==', cartId)
      .get();

    if (cartDetailsSnapshot.empty) {
      return res.status(404).json({ message: 'No items found in the cart.' });
    }

    // Fetch user details
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      return res.status(404).json({ message: 'User not found.' });
    }
    const userData = userDoc.data();

    // Validate shipping address
    const shippingAddressDoc = await db.collection('addresses').doc(shippingAddressId).get();
    if (!shippingAddressDoc.exists || shippingAddressDoc.data().userId !== userId) {
      return res.status(403).json({ message: 'Invalid or unauthorized shipping address.' });
    }

    // Initialize order values
    let subTotal = 0, yourSaving = 0;
    const orderDetails = [];
    const orderId = uuidv4();

    // Fetch product units in parallel
    const productUnitsPromises = cartDetailsSnapshot.docs.map(async (doc) => {
      const detail = doc.data();
      const productUnitDoc = await db.collection('product_units').doc(detail.productUnitId).get();
      if (!productUnitDoc.exists) throw new Error(`Product unit ${detail.productUnitId} not found.`);
      return { detail, productUnit: productUnitDoc.data() };
    });

    const productUnits = await Promise.all(productUnitsPromises);

    // Prepare order details
    productUnits.forEach(({ detail, productUnit }) => {
      const salePrice = parseFloat(productUnit.sale_price) || 0;
      const mrp = parseFloat(productUnit.mrp) || 0;

      const lineTotal = salePrice * detail.quantity;
      const savings = (mrp - salePrice) * detail.quantity;

      subTotal += lineTotal;
      yourSaving += savings;

      console.log("++++++++++++++++++++++++++++++++++++++++++++++++",detail);
      console.log("+++++++++++++++++++++++++++productUnitp+++++++++++++++++++++",productUnit);

      orderDetails.push({
        id: uuidv4(),
        orderId,
        productId: detail.productId,
        unitId: productUnit.unitId,
        image: productUnit.image || '',
        mrp,
        sale_price: salePrice,
        quantity: detail.quantity,
        delivered_quantity: 0,
        is_delivered: 0,
        last_updated_date: new Date().toISOString(),
        lastUpdatedById: userId,
      });
    });

    const totalAmountPayable = subTotal + parseFloat(deliveryCharge);
    const status = paymentMethod === 'Cash on Delivery' ? 'Cash on Delivery' : paymentMethod;
    const deliveryStatus = 'completed';
    const amountPaid = paymentMethod === 'Cash on Delivery' ? 0 : totalAmountPayable;

    // Handle Paytm payment
    if (paymentMethod.toLowerCase() === 'paytm') {
      // Validate Paytm configuration
      const requiredConfigs = [
        'PAYTM_MERCHANT_ID',
        'PAYTM_MERCHANT_KEY',
        'PAYTM_WEBSITE',
        'PAYTM_INDUSTRY_TYPE_ID',
        'PAYTM_CHANNEL_ID',
        'PAYTM_CALLBACK_URL',
        'PAYTM_ORDER_URL',
      ];

      const missingConfigs = requiredConfigs.filter(
        (key) => !paytmConfig[key] || paytmConfig[key].trim() === ''
      );

      if (missingConfigs.length > 0) {
        return res.status(500).json({ message: `Missing Paytm configuration: ${missingConfigs.join(', ')}` });
      }

      // Prepare Paytm parameters
      const paytmParamsRaw = {
        MID: paytmConfig.PAYTM_MERCHANT_ID,  // Make sure this is not empty or incorrect
        ORDER_ID: orderId,  // Ensure this is correctly set and passed
        CUST_ID: userId,  // Customer ID, typically userId
        INDUSTRY_TYPE_ID: paytmConfig.PAYTM_INDUSTRY_TYPE_ID,
        CHANNEL_ID: paytmConfig.PAYTM_CHANNEL_ID,
        TXN_AMOUNT: totalAmountPayable.toFixed(2),
        WEBSITE: paytmConfig.PAYTM_WEBSITE,
        EMAIL: userData.email || '',
        MOBILE_NO: userData.phone || '',
        CALLBACK_URL: paytmConfig.PAYTM_CALLBACK_URL,
      };
      
      

      // Convert all parameters to strings
      const paytmParams = stringifyParams(paytmParamsRaw);

      // Log Paytm parameters for debugging
      console.log('Paytm Params:');
      for (const [key, value] of Object.entries(paytmParams)) {
        console.log(`Key: ${key}, Type: ${typeof value}, Value: ${value}`);
      }

      // Log Paytm Merchant Key (Avoid logging sensitive data in production)
      console.log(`PAYTM_MERCHANT_KEY: Type: ${typeof paytmConfig.PAYTM_MERCHANT_KEY}, Value: ${paytmConfig.PAYTM_MERCHANT_KEY}`);

      try {
        // Check if PAYTM_MERCHANT_KEY is a non-empty string
        if (typeof paytmConfig.PAYTM_MERCHANT_KEY !== 'string' || paytmConfig.PAYTM_MERCHANT_KEY.trim() === '') {
          throw new Error('PAYTM_MERCHANT_KEY is not set or is not a valid string.');
        }

        // Generate checksum
        const checksum = await PaytmChecksum.generateSignature(paytmParams, paytmConfig.PAYTM_MERCHANT_KEY);
        const params = { ...paytmParams, CHECKSUMHASH: checksum };

        // Log the payload being sent to Paytm
        console.log('Payload sent to Paytm:', JSON.stringify(params, null, 2));

        // Initiate Paytm transaction
        const paytmResponse = await axios.post(paytmConfig.PAYTM_ORDER_URL, params, {
          headers: {
            'Content-Type': 'application/json',
          },
        });

        // Log Paytm response
        console.log('Paytm Response:', JSON.stringify(paytmResponse.data, null, 2));

        if (paytmResponse.status === 200) {
          const responseData = paytmResponse.data;
          if (responseData.body && responseData.body.txnToken) {
            const txnToken = responseData.body.txnToken;
            return res.status(201).json({
              message: 'Paytm transaction initiated successfully!',
              orderId,
              txnToken,
              callbackUrl: paytmConfig.PAYTM_CALLBACK_URL,
            });
          } else {
            console.error('Invalid Paytm response structure:', responseData);
            return res.status(500).json({ message: 'Invalid Paytm response structure.' });
          }
        } else {
          console.error('Error initiating Paytm transaction:', paytmResponse.data);
          return res.status(500).json({ message: 'Failed to initiate Paytm transaction.' });
        }
      } catch (error) {
        console.error('Paytm transaction error:', error.message);
        return res.status(500).json({ message: 'Error initiating Paytm transaction.', error: error.message });
      }
    } else {
      // Handle non-Paytm payments (e.g., Cash on Delivery, Pluxee)
      // Create Firestore batch
      const batch = db.batch();

      // Add order document
      batch.set(db.collection('orders').doc(orderId), {
        id: orderId,
        buyerEmail: userData.email || '',
        buyerPhone: userData.phone || '',
        sub_total: subTotal,
        shipping_total: parseFloat(deliveryCharge),
        your_saving: yourSaving,
        coupon_amount: 0,
        delivery_date: deliveryDate,
        status,
        delivery_status: deliveryStatus,
        paymentIntendId: paymentMethod === 'Cash on Delivery' ? 'CASH' : paymentIntendId,
        order_date: new Date().toISOString(),
        last_updated_date: new Date().toISOString(),
        userId,
        shippingAddressId,
        deliverySlotId: selectedSlotId,
        lastUpdatedById: userId,
        wallet_amount: 0,
        amount_paid: amountPaid,
        amount_refund: 0,
        total_amount: totalAmountPayable,
      });

      // Add order details
      orderDetails.forEach((orderDetail) => {
        batch.set(db.collection('order_details').doc(orderDetail.id), orderDetail);
      });

      // Remove items from cart
      cartDetailsSnapshot.docs.forEach((doc) => {
        batch.delete(db.collection('cart_details').doc(doc.id));
      });

      // Commit the batch
      await batch.commit();

      return res.status(201).json({
        message: 'Order placed successfully!',
        orderId,
      });
    }
  } catch (error) {
    console.error('Error creating order:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * Paytm Callback Handler
 * POST /api/orders/paytm/callback
 * Paytm will send payment response to this URL
 */
exports.paytmCallback = async (req, res) => {
  const paytmParams = req.body;

  // Extract all parameters
  const {
    ORDERID,
    TXNID,
    TXNAMOUNT,
    PAYMENTMODE,
    CURRENCY,
    TXNDATE,
    STATUS,
    RESPCODE,
    RESPMSG,
    GATEWAYNAME,
    BANKTXNID,
    BANKNAME,
    CHECKSUMHASH
  } = paytmParams;

  // Verify checksum
  const checksum = CHECKSUMHASH;
  delete paytmParams.CHECKSUMHASH;

  // Convert paytmParams keys to lowercase to match PaytmChecksum requirements
  const paytmParamsLower = {};
  for (const key in paytmParams) {
    if (paytmParams.hasOwnProperty(key)) {
      paytmParamsLower[key.toLowerCase()] = paytmParams[key];
    }
  }

  const isValidChecksum = PaytmChecksum.verifySignature(
    paytmParamsLower,
    paytmConfig.PAYTM_MERCHANT_KEY || '',
    checksum
  );

  if (!isValidChecksum) {
    console.error('Checksum verification failed.');
    return res.status(400).json({ message: 'Checksum mismatch.' });
  }

  // Log the received parameters for debugging
  console.log('Paytm Callback Params:', JSON.stringify(paytmParams, null, 2));

  // Proceed based on payment status
  if (STATUS === 'TXN_SUCCESS') {
    try {
      // Fetch order details using ORDERID
      const orderDoc = await db.collection('orders').doc(ORDERID).get();

      if (!orderDoc.exists) {
        console.error(`Order with ID ${ORDERID} not found.`);
        return res.status(404).json({ message: 'Order not found.' });
      }

      const orderData = orderDoc.data();

      // Check if the order is already paid to prevent duplicate processing
      if (orderData.paymentStatus === 'success') {
        console.warn(`Order ${ORDERID} has already been processed.`);
        return res.status(200).json({ message: 'Order already processed.' });
      }

      // Create Firestore batch
      const batch = db.batch();

      // Update order status
      const orderRef = db.collection('orders').doc(ORDERID);
      batch.update(orderRef, {
        delivery_status: 'completed',
        status: 'Paid',
        paymentStatus: 'success',
        last_updated_date: new Date().toISOString(),
        txnId: TXNID,
        txnAmount: parseFloat(TXNAMOUNT),
        paymentMode: PAYMENTMODE,
        currency,
        txnDate: TXNDATE,
        respCode: RESPCODE,
        respMsg: RESPMSG,
        gatewayName: GATEWAYNAME,
        bankTxnId: BANKTXNID,
        bankName: BANKNAME,
      });

      // Remove items from cart based on the order
      // Assuming orderData has a cartId field
      const cartId = orderData.cartId;
      if (cartId) {
        const cartDetailsSnapshot = await db.collection('cart_details').where('cartId', '==', cartId).get();
        cartDetailsSnapshot.docs.forEach((doc) => {
          batch.delete(db.collection('cart_details').doc(doc.id));
        });
      }

      // Commit the batch
      await batch.commit();

      // Redirect to success page
      res.redirect('/payment-success'); // Adjust to your frontend route
    } catch (error) {
      console.error('Error processing successful Paytm transaction:', error.message);
      res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  } else {
    try {
      // Handle failed or cancelled transactions
      // Optionally, you can update the order status to 'Payment Failed'

      // Fetch order details using ORDERID
      const orderDoc = await db.collection('orders').doc(ORDERID).get();

      if (orderDoc.exists) {
        const batch = db.batch();
        const orderRef = db.collection('orders').doc(ORDERID);
        batch.update(orderRef, {
          delivery_status: 'failed',
          status: 'Payment Failed',
          paymentStatus: 'failed',
          last_updated_date: new Date().toISOString(),
          txnId: TXNID || '',
          txnAmount: parseFloat(TXNAMOUNT) || 0,
          paymentMode: PAYMENTMODE || '',
          currency: CURRENCY || '',
          txnDate: TXNDATE || '',
          respCode: RESPCODE || '',
          respMsg: RESPMSG || '',
          gatewayName: GATEWAYNAME || '',
          bankTxnId: BANKTXNID || '',
          bankName: BANKNAME || '',
        });

        // Commit the batch
        await batch.commit();
      } else {
        console.error(`Order with ID ${ORDERID} not found for failed transaction.`);
      }

      // Redirect to failure page
      res.redirect('/payment-failure'); // Adjust to your frontend route
    } catch (error) {
      console.error('Error processing failed Paytm transaction:', error.message);
      res.status(500).json({ message: 'Internal server error', error: error.message });
    }
  }
};

/**
 * Get Order by ID
 * GET /api/orders/:orderId
 */
exports.getOrderById = async (req, res) => {
  const { orderId } = req.params;
  const userId = req.user.id;

  try {
    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists || orderDoc.data().userId !== userId) {
      return res.status(404).json({ message: 'Order not found or unauthorized.' });
    }

    const orderDetailsSnapshot = await db
      .collection('order_details')
      .where('orderId', '==', orderId)
      .get();

    const orderDetails = orderDetailsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    return res.status(200).json({ order: orderDoc.data(), orderDetails });
  } catch (error) {
    console.error('Error fetching order by ID:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};

/**
 * Get All Orders for Authenticated User
 * GET /api/orders/user/all
 */
exports.getUserOrders = async (req, res) => { 
  const userId = req.user.id;  // Assumes you have userId from authentication middleware
  
  try {
    console.log("Fetching orders for userId:", userId);

    // Query the orders collection
    const ordersSnapshot = await db
      .collection('orders')
      .where('userId', '==', userId)
      .get();

    if (ordersSnapshot.empty) {
      console.log("No orders found for userId:", userId);
      return res.status(404).json({ message: 'No orders found for the user.' });
    }

    const orders = [];

    // Loop through each order and fetch its details
    for (const orderDoc of ordersSnapshot.docs) {
      const orderData = { id: orderDoc.id, ...orderDoc.data() };

      // Fetch associated order details
      const orderDetailsSnapshot = await db
        .collection('order_details')
        .where('orderId', '==', orderDoc.id)
        .get();

      const orderDetails = orderDetailsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      // Push each order with its details
      orders.push({
        order: orderData,
        orderDetails,
      });
    }





    

    // Send the orders as a response
    return res.status(200).json({ orders });
  } catch (error) {
    console.error('Error fetching user orders:', error.message);
    return res.status(500).json({ message: 'Internal server error', error: error.message });
  }
};
