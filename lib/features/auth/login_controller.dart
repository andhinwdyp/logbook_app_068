class LoginController {
  // 1. Data User yang lebih pintar (bisa banyak user)
  final Map<String, String> _userData = {
    "Admin": "123",
    "Guest": "321",
  };

  int failedAttempts = 0;

  // 2. Fungsi Login yang lebih pintar
  bool login(String username, String password) {
    // Cek apakah username dan password tidak kosong
    if (username.isEmpty || password.isEmpty) {
      return false; 
    }

    // Cek apakah username ada dan password cocok 
    if (_userData.containsKey(username) && _userData[username] == password) {
      failedAttempts = 0; // Reset hitungan jika berhasil login
      return true;
    }
    
    failedAttempts++; // Tambah hitungan jika gagal
    return false;
  }
}