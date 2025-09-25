import 'dart:convert';
import 'package:flutter/services.dart';

class Configuration {
  static Future<Map<String, dynamic>> getConfig() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/config/config.json',
      );
      return jsonDecode(jsonString);
    } catch (e) {
      // Log the error and return an empty map or handle it as needed
      print('Error loading or parsing config.json: $e');
      return {};
    }
  }
}
