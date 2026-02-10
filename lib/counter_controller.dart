class CounterController {
  int _counter = 0;
  int _step = 1; // Variabel untuk menyimpan besarnya langkah (Task 1)

  // Getter (agar variabel aman/encapsulated)
  int get value => _counter;
  int get step => _step;

  // Fungsi Logika
  void increment() {
    _counter += _step; // Tambah sesuai step
  }

  void decrement() {
    // Opsional: Mencegah nilai negatif
    if (_counter >= _step) {
      _counter -= _step;
    } else {
      _counter = 0;
    }
  }

  void reset() {
    _counter = 0;
  }

  void setStep(int value) {
    _step = value;
  }
}