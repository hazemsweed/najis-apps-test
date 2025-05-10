import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:najih_education_app/constants/api_config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'auth_state.dart';

class GeneralService {
  static late BuildContext globalContext;

  static void init(BuildContext context) {
    globalContext = context;
  }

  Map<String, String> get _headers {
    final token = Provider.of<AuthState>(globalContext, listen: false).token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ───────────────── Fetch all items
  Future<List<dynamic>> getItems(String route) async {
    final response =
        await http.get(Uri.parse(ApiConfig.baseUrl + route), headers: _headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load data: ${response.reasonPhrase}');
  }

  // ───────────────── Fetch items with query
  Future<List<dynamic>> getItemsWithQuery(
      String route, Map<String, String> queryParams) async {
    final uri = Uri.parse(ApiConfig.baseUrl + route)
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load data: ${response.reasonPhrase}');
  }

  // ───────────────── Fetch single item
  Future<Map<String, dynamic>> getItem(String route, String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}$route/$id'),
        headers: _headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load item: ${response.reasonPhrase}');
  }

  // ───────────────── Add item
  Future<Map<String, dynamic>> addItem(
      String route, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + route),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add item: ${response.reasonPhrase}');
  }

  // ───────────────── Edit item
  Future<Map<String, dynamic>> editItem(
      String route, String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$route/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to edit item: ${response.reasonPhrase}');
  }

  // ───────────────── Delete item
  Future<void> deleteItem(String route, String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$route/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.reasonPhrase}');
    }
  }
}
