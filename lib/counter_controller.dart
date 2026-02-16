class CounterController {
  int _counter = 0;
  int _step = 1;
  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  final List<int> stepOptions = [1, 5, 10, 25, 50, 100];

  void _addHistory(String message) {
    DateTime now = DateTime.now();
    String timestamp =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    _history.insert(0, "$message ($timestamp)");

    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  void increment() {
    _counter += _step;
    _addHistory("NAIK +$_step");
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
      _addHistory("TURUN -$_step");
    } else {
      _counter = 0;
      _addHistory("MENTOK KE 0");
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("RESET DATA");
  }

  void setStep(int value) {
    _step = value;
  }
}