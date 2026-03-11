import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String _url = "https://jsonplaceholder.typicode.com/users";

  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<User> createUser(String name) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<User> updateUser(int id, String name) async {
    final response = await http.put(
      Uri.parse('$_url/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$_url/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}