import 'dart:convert';
import 'package:gestortarea_app/task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final String baseUrl = 'http://localhost:5222/api/task'; // Ajusta la URL

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add task');
    }
  }

  Future<void> completeTask(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id/complete'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to complete task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }

  Future<Map<String, int>> getTaskStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        final data = responseData['data'];
        return {
          'completed': data['completed'],
          'pending': data['pending'],
          'deleted': data['deleted'],
        };
      }
    }
    throw Exception('Failed to load task stats');
  }
}
