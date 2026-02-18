import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  // --- FUNGSI BARU: MEMUAT DATA (LOAD) ---
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt('counter_key') ?? 0;
    _step = prefs.getInt('step_key') ?? 1;
    _history = prefs.getStringList('history_key') ?? [];
  }

  // --- FUNGSI BARU: MENYIMPAN DATA (SAVE) ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('counter_key', _counter);
    await prefs.setInt('step_key', _step);
    await prefs.setStringList('history_key', _history);
  }

  void setStep(int step) {
    _step = step;
    _saveData();
  }

  void increment() {
    _counter += _step;
    _addLog("NAIK $_step Angka");
    _saveData();
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
      _addLog("TURUN $_step Angka");
      _saveData();
    }
  }

  void reset() {
    _counter = 0;
    _history.clear();
    _addLog("DATA DIRESET");
    _saveData();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    String time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    _history.insert(0, "[$time] $message");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}