class ApiUrl {
  static const String baseApiUrl = 'http://10.0.2.2:5000';

  static String getVehiclesUrl() {
    return '$baseApiUrl/vehicles';
  }

  static String updateVehicleUrl(int vehicleId) {
    return '$baseApiUrl/vehicles/$vehicleId';
  }
}