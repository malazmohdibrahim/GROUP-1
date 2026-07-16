import 'dart:convert';

import 'package:http/http.dart' as http;

// Handles permanent data storage using the online MySQL API.
// Flutter sends requests to PHP files, and PHP communicates with MySQL.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static const String _baseUrl =
      'http://aura-tech.infinityfree.io/study_planner_api';

  DatabaseHelper._init();

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return jsonDecode(response.body.trim()) as Map<String, dynamic>;
  }

  Future<int> insertGoal({required String subject, required int hours}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add_goal.php'),
      body: {'subject': subject, 'hours': hours.toString()},
    );

    final data = _decodeResponse(response);
    if (data['success'] == true) {
      return int.parse(data['id'].toString());
    }

    throw Exception(data['message'] ?? 'Failed to add goal');
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    final response = await http.get(Uri.parse('$_baseUrl/get_goals.php'));
    final data = _decodeResponse(response);

    if (data['success'] == true) {
      final goals = data['goals'] as List<dynamic>;
      return goals.map((goal) => Map<String, dynamic>.from(goal)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to load goals');
  }

  Future<int> updateGoalDone({required int id, required bool done}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/update_goal.php'),
      body: {'id': id.toString(), 'done': done ? '1' : '0'},
    );

    final data = _decodeResponse(response);
    if (data['success'] == true) {
      return 1;
    }

    throw Exception(data['message'] ?? 'Failed to update goal');
  }

  Future<int> deleteGoal(int id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/delete_goal.php'),
      body: {'id': id.toString()},
    );

    final data = _decodeResponse(response);
    if (data['success'] == true) {
      return 1;
    }

    throw Exception(data['message'] ?? 'Failed to delete goal');
  }
}
