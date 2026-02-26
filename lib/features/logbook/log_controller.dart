import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart'; 

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  String _activeUser = "guest"; 

  Future<void> loadData(String username) async {
    _activeUser = username;
    await loadFromDisk();
  }

  void searchLog(String query) {
    if (query.isEmpty) {
      filteredLogsNotifier.value = logsNotifier.value;
    } else {
      filteredLogsNotifier.value = logsNotifier.value
          .where((log) => log.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
      category: category,
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    filteredLogsNotifier.value = logsNotifier.value;
    saveToDisk();
  }

  void updateLog(int index, String title, String desc, String category) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString(),
      category: category
    );
    logsNotifier.value = currentLogs;
    filteredLogsNotifier.value = currentLogs;
    saveToDisk();
  }

  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    filteredLogsNotifier.value = currentLogs;
    saveToDisk();
  }
  
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(logsNotifier.value.map((e) => e.toMap()).toList());
    await prefs.setString('user_logs_$_activeUser', encodedData);
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('user_logs_$_activeUser');
    
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
      filteredLogsNotifier.value = logsNotifier.value;
    }
  }
}