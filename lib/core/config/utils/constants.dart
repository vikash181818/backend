class Constants {
  static const baseUrl = "http://192.168.68.116:3000";
  static const apiUrl = "$baseUrl/api";
  static const apiUserUrl = "$apiUrl/user";

  static const String addressUrl = '$apiUrl/address';

  static const String stateEndpoint = "$addressUrl/state";
  static const String carouselEndpoint = "$apiUrl/carousel";

  static const signupEndpoint = "$apiUserUrl/signup";
  static const loginEndpoint = "$apiUserUrl/user-login";
  static const manageProductApi = "$apiUrl/manageProducts";
  static const productUnits = "$manageProductApi/units";
  static const productsWithUnitsByCategory =
      "$manageProductApi/products_with_units_by_category";
  static const productsWithUnitsListAllProducts =
      "$manageProductApi/products_with_units";

  static const isSeasonal = "$manageProductApi/is_seasonal";

  static const isNewLaunch = "$manageProductApi/is_new_launch";

  static const isRecomendad = "$manageProductApi/is_Recommendad";

  static const previousOrder =
      "http://98.70.35.28:3000/api/manageProducts/previous_orders";
}
