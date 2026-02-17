import 'package:flutter/material.dart';
import 'package:logbook_app_068/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;

  final List<Map<String, String>> _onboardingData = [
  {
    "title": "Mulai Perubahan Hari Ini",
    "desc":
        "Setiap progres besar dimulai dari langkah kecil. Catat, pantau, dan buktikan bahwa konsistensi membawa hasil.",
  },
  {
    "title": "Kontrol Penuh atas Targetmu",
    "desc":
        "Atur langkahmu sendiri dan lihat bagaimana setiap peningkatan membawa kamu lebih dekat ke tujuan.",
  },
  {
    "title": "Bangun Disiplin, Raih Hasil",
    "desc":
        "Dengan sistem yang aman dan terorganisir, fokuslah pada pertumbuhan tanpa gangguan.",
  },
];


  void _nextStep() {
    if (_step < 3) {
      setState(() {
        _step++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _onboardingData[_step - 1];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ILUSTRASI / GAMBAR ---
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _step == 1
                      ? Icons.waving_hand
                      : _step == 2
                          ? Icons.bar_chart
                          : Icons.security,
                  size: 80,
                  color: const Color(0xFFB8E0D2),
                ),
              ),
              
              const SizedBox(height: 40),

              // --- TEKS JUDUL & DESKRIPSI ---
              Text(
                "Halaman $_step", 
                style: const TextStyle(color: Colors.grey, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                data["title"]!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data["desc"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const Spacer(),

              // --- TOMBOL LANJUT ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8C8DC),
                    foregroundColor: const Color(0xFF4A4A4A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _nextStep,
                  child: Text(
                    _step == 3 ? "MULAI SEKARANG" : "LANJUT",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}