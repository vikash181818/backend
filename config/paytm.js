// config/paytm.js

module.exports = {
    PAYTM_ENVIRONMENT: 'TEST', // Change to 'PROD' for production
    PAYTM_MERCHANT_ID: 'gdVbCH83095356609000', // Replace with your Test Merchant ID
    PAYTM_MERCHANT_KEY: 'OVgptrdBx2RgXu@7', // Replace with your Test Merchant Key
    PAYTM_CHANNEL_ID: 'WEB', // Typically 'WEB' or 'WAP'
    PAYTM_WEBSITE: 'WEBSTAGING', // 'WEBSTAGING' for testing, 'DEFAULT' for production
    PAYTM_INDUSTRY_TYPE_ID: 'Retail', // As per your business type
    //PAYTM_CALLBACK_URL: 'https://yourdomain.com/api/orders/paytm/callback', // Ensure HTTPS
    PAYTM_ORDER_URL: 'https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction', // For testing
    // PAYTM_ORDER_URL: 'https://securegw.paytm.in/theia/api/v1/initiateTransaction', // For production
  };
  