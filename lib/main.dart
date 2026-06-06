import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // 1. Flutter widget ağacının hazır olduğundan emin ol (Bu satır hayati önem taşır!)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase'i başlat ama hata verirse uygulamayı kilitleme
  try {
    await Firebase.initializeApp();
    print("Firebase BAŞARIYLA başlatıldı! 🔥");
  } catch (e) {
    print("DİKKAT: Firebase başlatılırken hata oluştu: $e");
  }
  runApp(const MotorAsistaniApp());
}

class MotorAsistaniApp extends StatelessWidget {
  const MotorAsistaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  // Hocanın uyardığı belirsizlikleri gideren giriş kutucukları
  final TextEditingController tCycleController = TextEditingController();
  final TextEditingController nMaxController = TextEditingController();
  final TextEditingController tNominalController = TextEditingController();

  bool isLoadSide = true; // Veriler yükte mi motorda mı?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Boyutlandırma Asistanı"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Sistem Parametrelerini Giriniz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Toplam Çevrim Süresi (Hocanın şartı)
            TextField(
              controller: tCycleController,
              decoration: const InputDecoration(
                labelText: "Toplam Çevrim Süresi (t_cycle - sn)",
                border: OutlineInputBorder(),
                helperText: "Termal hesaplamalar için bu alan zorunludur.",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            // Maksimum Hız (Hocanın şartı)
            TextField(
              controller: nMaxController,
              decoration: const InputDecoration(
                labelText: "Gerekli Maksimum Hız (n_max - rpm)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            // Nominal Tork Girişi
            TextField(
              controller: tNominalController,
              decoration: const InputDecoration(
                labelText: "Gerekli Sürekli Tork (Nm)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            // Referans Tarafı Seçimi (Dönüşüm hatasını önlemek için)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SwitchListTile(
                title: Text(
                  isLoadSide
                      ? "Referans: YÜK TARAFI"
                      : "Referans: MOTOR TARAFI",
                ),
                subtitle: const Text(
                  "Hesaplamaların hangi mile göre yapılacağını seçin.",
                ),
                value: isLoadSide,
                onChanged: (val) => setState(() => isLoadSide = val),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Firebase'deki Motors/motor_001 verisini çekip kıyaslayacağız
                print("Hesaplama ve Firebase eşleştirmesi başlatılıyor...");
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
              child: const Text(
                "HESAPLA VE MOTOR ÖNER",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
