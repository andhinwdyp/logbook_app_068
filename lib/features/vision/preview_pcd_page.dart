import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

// ============================================================================
// FUNGSI BERAT (ISOLATE): Berjalan di background thread agar UI tidak macet
// ============================================================================
Future<Uint8List> processPCDHeavy(Map<String, dynamic> params) async {
  String operation = params['operation'];
  Uint8List currentBytes = params['bytes'];

  // 1. Decode gambar dari bytes
  img.Image? decodedImage = img.decodeImage(currentBytes);
  if (decodedImage == null) return currentBytes;

  // 2. Operasi Spasial & Statistik
  if (operation == 'lowpass') {
    // Lowpass = Blur (Menghilangkan detail tajam/noise)
    decodedImage = img.gaussianBlur(decodedImage, radius: 3);
  } 
  else if (operation == 'highpass') {
    // Highpass = Edge Detection (Mendeteksi tepi retakan aspal)
    final kernel = [
      -1, -1, -1,
      -1,  8, -1,
      -1, -1, -1
    ];
    decodedImage = img.convolution(decodedImage, filter: kernel, div: 1, offset: 0);
  } 
  else if (operation == 'saltpepper') {
    // Injeksi Salt & Pepper Noise (5% probabilitas)
    var random = Random();
    for (var p in decodedImage) {
      if (random.nextDouble() < 0.05) {
        bool isSalt = random.nextBool();
        p.r = isSalt ? 255 : 0;
        p.g = isSalt ? 255 : 0;
        p.b = isSalt ? 255 : 0;
      }
    }
  }

  // 3. Encode kembali ke JPG
  return img.encodeJpg(decodedImage, quality: 90);
}


// ============================================================================
// KELAS UI UTAMA
// ============================================================================
class PreviewPCDPage extends StatefulWidget {
  final String imagePath;

  const PreviewPCDPage({super.key, required this.imagePath});

  @override
  State<PreviewPCDPage> createState() => _PreviewPCDPageState();
}

class _PreviewPCDPageState extends State<PreviewPCDPage> {
  // State untuk Isolate & Gambar Mentah
  bool _isLoading = false;
  late Uint8List _imageBytes; // Menyimpan status gambar saat ini

  // Nilai Awal Slider (Point Operations)
  double _brightness = 0.0; 
  double _contrast = 1.0;   
  double _saturation = 1.0; 
  String _selectedFilter = 'Normal';
  String _activeEffect = '';

  @override
  void initState() {
    super.initState();
    // Muat gambar asli ke memori pertama kali
    _imageBytes = File(widget.imagePath).readAsBytesSync();
  }

  // --- MATRIKS PCD (Tetap menggunakan GPU agar cepat) ---
  List<double> get _bcMatrix {
    double c = _contrast < 0.3 ? 0.3 : _contrast;
    double b = _brightness * 150.0;
    double t = 128.0 * (1.0 - c) + b;
    return [
      c, 0, 0, 0, t, 
      0, c, 0, 0, t, 
      0, 0, c, 0, t, 
      0, 0, 0, 1, 0, 
    ];
  }

  List<double> get _saturationMatrix {
    double s = _saturation;
    double invS = 1.0 - s;
    double rW = 0.299 * invS;
    double gW = 0.587 * invS;
    double bW = 0.114 * invS;
    return [
      rW + s, gW,     bW,     0, 0,
      rW,     gW + s, bW,     0, 0,
      rW,     gW,     bW + s, 0, 0,
      0,      0,      0,      1, 0,
    ];
  }

  List<double> get _filterMatrix {
    switch (_selectedFilter) {
      case 'Grayscale':
        return [
          0.299, 0.587, 0.114, 0, 0,
          0.299, 0.587, 0.114, 0, 0,
          0.299, 0.587, 0.114, 0, 0,
          0,     0,     0,     1, 0,
        ];
      case 'Invert': 
        return [
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1, 0,
        ];
      case 'Sepia': 
        return [
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0,     0,     0,     1, 0,
        ];
      default: 
        return [
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ];
    }
  }

  // FUNGSI PEMICU ISOLATE
  void _applySpatialOperation(String operation) async {
    setState(() => _isLoading = true);

    if (operation == 'reset') {
      _imageBytes = File(widget.imagePath).readAsBytesSync();
      setState(() => _activeEffect = '');
    } else {
      setState(() => _activeEffect = operation);
      final resultBytes = await compute(processPCDHeavy, {
        'operation': operation,
        'bytes': _imageBytes,
      });
      _imageBytes = resultBytes;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Manipulasi Gambar", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // AREA KANVAS GAMBAR DENGAN LOADING OVERLAY
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.matrix(_filterMatrix),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(_saturationMatrix),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(_bcMatrix),
                        child: Image.memory(
                          _imageBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // AREA PANEL KONTROL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Filter Lensa & Efek:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'Normal';
                          _brightness = 0.0;
                          _contrast = 1.0;
                          _saturation = 1.0;
                          _activeEffect = '';
                        });
                        _applySpatialOperation('reset'); 
                      },
                      icon: const Icon(Icons.restore, size: 14, color: Colors.redAccent),
                      label: const Text("Pulihkan", style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // DERETAN FILTER WARNA-WARNI (Tanpa Garis Pembatas)
                SizedBox(
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // --- Group 1: Lensa Warna ---
                      _buildPillButton("Normal", _selectedFilter == 'Normal', Colors.grey, 
                        () => setState(() => _selectedFilter = 'Normal')),
                      _buildPillButton("Grayscale", _selectedFilter == 'Grayscale', Colors.grey, 
                        () => setState(() => _selectedFilter = 'Grayscale')),
                      _buildPillButton("Sepia", _selectedFilter == 'Sepia', Colors.grey, 
                        () => setState(() => _selectedFilter = 'Sepia')),
                      _buildPillButton("Invert", _selectedFilter == 'Invert', Colors.grey, 
                        () => setState(() => _selectedFilter = 'Invert')),

                      // --- Group 2: Efek Spasial ---
                      _buildPillButton("Blur", _activeEffect == 'lowpass', Colors.grey, 
                        () => _isLoading ? null : _applySpatialOperation('lowpass')),
                      _buildPillButton("Sharpen", _activeEffect == 'highpass', Colors.grey, 
                        () => _isLoading ? null : _applySpatialOperation('highpass')),
                      _buildPillButton("Noise", _activeEffect == 'saltpepper', Colors.grey, 
                        () => _isLoading ? null : _applySpatialOperation('saltpepper')),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                
                // Slider Manipulasi
                _buildSlider(Icons.light_mode, "Brightness", _brightness, -1.0, 1.0, Colors.orange, 
                  (v) => setState(() => _brightness = v),
                  () => setState(() => _brightness = 0.0), // Aksi Reset Kecerahan
                ),
                _buildSlider(Icons.contrast, "Contrast", _contrast, 0.0, 3.0, Colors.blue, 
                  (v) => setState(() => _contrast = v),
                  () => setState(() => _contrast = 1.0), // Aksi Reset Kontras
                ),
                _buildSlider(Icons.color_lens, "Saturation", _saturation, 0.0, 2.0, Colors.pinkAccent, 
                  (v) => setState(() => _saturation = v),
                  () => setState(() => _saturation = 1.0), // Aksi Reset Saturasi
                ),

                const SizedBox(height: 5),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text("Selesai & Simpan"),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Tombol Pil (Pill Button) dengan Animasi dan Indikator Aktif
  Widget _buildPillButton(String label, bool isSelected, MaterialColor colorBase, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorBase : colorBase.shade100, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colorBase : Colors.transparent, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Slider dengan Reset
  Widget _buildSlider(IconData icon, String label, double val, double min, double max, Color color, Function(double) onChanged, VoidCallback onReset) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        Expanded(
          child: Slider(value: val, min: min, max: max, activeColor: color, onChanged: onChanged),
        ),
        IconButton(
          icon: const Icon(Icons.restore, size: 18, color: Colors.grey),
          onPressed: onReset,
          tooltip: "Reset $label",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}