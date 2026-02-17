class LoginController {
  // 1. Data User yang lebih pintar (bisa banyak user)
  final Map<String, String> _userData = {
    "admin": "123",
    "guest": "321",
  };

  // 2. Fungsi Login yang lebih pintar
  bool login(String username, String password) {
    // Cek apakah username dan password tidak kosong
    if (username.isEmpty || password.isEmpty) {
      return false; 
    }

    // Cek apakah username ada dan password cocok
    if (_userData.containsKey(username) && _userData[username] == password) {
      return true;
    }
    
    return false;
  }
}