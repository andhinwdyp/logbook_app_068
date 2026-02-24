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
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ),
      );
    }
  }

  void _prevStep() {
    if (_step > 1) {
      setState(() {
        _step--;
      });
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
              // --- GAMBAR ---
              SizedBox(
                height: 350,
                child: Image.network(
                  _step == 1
                      ? "https://i.pinimg.com/736x/1f/80/de/1f80dea09a25b0b596368ebf5ca86fe4.jpg"
                      : _step == 2
                          ? "https://i.pinimg.com/1200x/06/93/de/0693de4fddd8dbc6602760e311a44b38.jpg"
                          : "https://i.pinimg.com/1200x/7f/ea/61/7fea618dd67514a0c256fbbe29740337.jpg",
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF8C8DC),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Gagal memuat gambar",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- TEKS ---
              Text(
                "Halaman $_step",
                style: const TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data["title"]!,
                textAlign: TextAlign.center,
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              // --- TOMBOL ---
              Row(
                children: [
                  if (_step > 1) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A4A4A),
                          side: const BorderSide(
                            color: Color(0xFFF8C8DC),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _prevStep,
                        child: const Text(
                          "KEMBALI",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],

                  Expanded(
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
                        _step == 3 ? "MULAI" : "LANJUT",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}