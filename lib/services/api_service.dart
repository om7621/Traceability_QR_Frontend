import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/panel_model.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "https://traceability-qr-backend.azurewebsites.net";

  Future<Panel?> fetchPanelDetails(String panelId) async {
    final bool isAuthenticated = AuthService().isAuthenticated;
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_panel_details?id=$panelId&authenticated=$isAuthenticated'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Panel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception("Panel not registered in system");
      } else {
        throw Exception("Failed to load panel details");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> raiseTicket(String panelId, String description, String contactInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/raise_ticket'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'panelId': panelId,
          'description': description,
          'contactInfo': contactInfo,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
