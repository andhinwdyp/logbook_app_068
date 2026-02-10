class CounterController {
  int _counter = 0;
  int _step = 1;
  
  // 1. Variabel List untuk menyimpan riwayat (Task 2)
  final List<String> _history = [];

  // Getter
  int get value => _counter;
  int get step => _step;
  List<String> get history => _history; // Agar View bisa baca list-nya

  // --- LOGIKA PENCATATAN RIWAYAT (HOTS) ---
  void _addHistory(String message) {
    // Tambahkan pesan baru ke urutan paling atas (index 0)
    // DateTime.now() agar terlihat canggih ada jamnya
    String timestamp = "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    _history.insert(0, "[$timestamp] $message");

    // Logic Limit 5 Data:
    // Jika panjang list lebih dari 5, hapus yang paling bawah (terlama)
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  // --- FUNGSI UTAMA ---
  void increment() {
    _counter += _step;
    _addHistory("Ditambah $_step"); // Catat riwayat
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
      _addHistory("Dikurang $_step"); // Catat riwayat
    } else {
      _counter = 0;
      _addHistory("Dikurang mentok ke 0");
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("Data di-reset"); // Catat riwayat
  }

  void setStep(int value) {
    _step = value;
    // Gak perlu dicatat ke history, tapi kalau mau boleh aja
  }
}