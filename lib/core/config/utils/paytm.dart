// lib/core/config/utils/paytm_config.dart

class PaytmConfig {
  static const String PAYTM_MERCHANT_ID = 'gdVbCH83095356609000'; // Replace with your actual MID
  static const String PAYTM_WEBSITE = 'WEBSTAGING'; // 'WEBSTAGING' for testing, 'DEFAULT' for production
  static const String PAYTM_CALLBACK_URL = 'https://yourdomain.com/api/orders/paytm/callback'; // Replace with your actual callback URL
  static const String PAYTM_ORDER_URL = 'https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction'; // Testing URL
  // For production, use: 'https://securegw.paytm.in/theia/api/v1/initiateTransaction'
  static const String PAYTM_INDUSTRY_TYPE_ID = 'Retail'; // As per your business type
  static const String PAYTM_CHANNEL_ID = 'WEB'; // Typically 'WEB' or 'WAP'
}
