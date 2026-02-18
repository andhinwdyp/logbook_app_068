import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  List<String> _history = [];

  String _activeUser = "guest";

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  Future<void> loadData(String username) async {
    _activeUser = username;
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt('counter_$_activeUser') ?? 0;
    _step = prefs.getInt('step_$_activeUser') ?? 1;
    _history = prefs.getStringList('history_$_activeUser') ?? [];
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('counter_$_activeUser', _counter);
    await prefs.setInt('step_$_activeUser', _step);
    await prefs.setStringList('history_$_activeUser', _history);
  }

  void setStep(int step) {
    _step = step;
    _saveData();
  }

  void increment() {
    _counter += _step;
    _addLog("Naik +$_step");
    _saveData();
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
      _addLog("Turun -$_step");
      _saveData();
    }
  }

  void reset() {
    _counter = 0;
    _history.clear();
    _addLog("Data direset");
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