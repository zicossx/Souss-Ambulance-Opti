import 'api_service.dart';
import '../models/driver_model.dart';

class DriverService {
  // Register a new driver
  static Future<Driver> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String licenseNumber,
    required String vehicleNumber,
  }) async {
    final response = await ApiService.post('driver_register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'license_number': licenseNumber,
      'vehicle_number': vehicleNumber,
    });

    if (response['success'] == true) {
      return Driver.fromJson(response['driver']);
    } else {
      throw Exception(response['message'] ?? 'Registration failed');
    }
  }

  // Login driver
  static Future<Driver> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('driver_login', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      return Driver.fromJson(response['driver']);
    } else {
      throw Exception(response['message'] ?? 'Login failed');
    }
  }
}