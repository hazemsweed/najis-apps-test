import 'dart:convert';
import 'package:http/http.dart' as http;

class GeneralService {
  static const String baseUrl = 'https://nserver.najih1.com/';

  // Fetch all items without query
  Future<List<dynamic>> getItems(String route) async {
    final response = await http.get(Uri.parse(baseUrl + route));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

  // Fetch items with query parameters
  Future<List<dynamic>> getItemsWithQuery(
      String route, Map<String, String> queryParams) async {
    final uri =
        Uri.parse(baseUrl + route).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

  // Fetch single item
  Future<Map<String, dynamic>> getItem(String route, String id) async {
    final response = await http.get(Uri.parse('$baseUrl$route/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load item: ${response.reasonPhrase}');
    }
  }

  // Add item
  Future<Map<String, dynamic>> addItem(
      String route, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl + route),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add item: ${response.reasonPhrase}');
    }
  }

  // Edit item
  Future<Map<String, dynamic>> editItem(
      String route, String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$route/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to edit item: ${response.reasonPhrase}');
    }
  }

  // Delete item
  Future<void> deleteItem(String route, String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$route/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.reasonPhrase}');
    }
  }
}
