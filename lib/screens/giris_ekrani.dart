import 'package:flutter/material.dart';
import '../models/giris_parametreleri.dart';
import '../services/firebase_servis.dart';
import '../services/hesaplama_motoru.dart';
import 'sonuc_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();

  final _surekliTorkCtrl = TextEditingController(text: '20');
  final _tepeTorkCtrl = TextEditingController(text: '60');
  final _cevrimSuresiCtrl = TextEditingController(text: '10');
  final _tepeSuresiCtrl = TextEditingController(text: '3');
  final _gucCtrl = TextEditingController();
  bool _yukTarafi = true;

  final _nominalHizCtrl = TextEditingController(text: '1460');
  final _maxHizCtrl = TextEditingController(text: '2000');

  String _beslemeTipi = 'AC_uc_faz';
  final _ortamSicCtrl = TextEditingController(text: '25');
  String _motorSinifi = 'tumu';

  bool _reduktorVar = false;
  final _reduktorOraniCtrl = TextEditingController(text: '1');
  final _mekanikVerimCtrl = TextEditingController(text: '1.0');
  final _guvenlikCtrl = TextEditingController(text: '1.25');

  bool _yukleniyor = false;

  Future<void> _hesaplaVeOner() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _yukleniyor = true);

    try {
      var motorlar = await FirebaseServis.motorlariGetir();

      if (motorlar.isEmpty) {
        await FirebaseServis.ornekMotorlariYukle();
        motorlar = await FirebaseServis.motorlariGetir();
        if (!mounted) return;
        if (motorlar.isEmpty) {
          _hataGoster('Motor veri tabanı boş ve yüklenemedi.');
          return;
        }
      }

      if (!mounted) return;

      final giris = GirisParametreleri(
        surekliTorkNm: double.parse(_surekliTorkCtrl.text),
        tepeTorkNm: double.parse(_tepeTorkCtrl.text),
        cevrimSuresiSn: double.parse(_cevrimSuresiCtrl.text),
        tepeSuresiSn: double.parse(_tepeSuresiCtrl.text),
        yukTarafi: _yukTarafi,
        nominalHizRpm: double.parse(_nominalHizCtrl.text),
        maxHizRpm: double.parse(_maxHizCtrl.text),
        beslemetipi: _beslemeTipi,
        ortamSicakligiC: double.parse(_ortamSicCtrl.text),
        motorSinifi: _motorSinifi,
        reduktorVar: _reduktorVar,
        reduktorOrani: _reduktorVar
            ? double.parse(_reduktorOraniCtrl.text)
            : 1.0,
        mekanikVerim: _reduktorVar ? double.parse(_mekanikVerimCtrl.text) : 1.0,
        guvenlikKatsayisi: double.parse(_guvenlikCtrl.text),
        girilenGucKw: _gucCtrl.text.isEmpty
            ? null
            : double.tryParse(_gucCtrl.text),
      );

      final rapor = HesaplamaMotoru.hesaplaVeOner(giris, motorlar);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SonucEkrani(rapor: rapor, girisParametreleri: giris),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _hataGoster(
        'Firebase bağlantı hatası:\n$e\n\n'
        'Firebase Console → Rules kısmını kontrol edin.',
      );
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _hataGoster(String mesaj) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hata'),
        content: Text(mesaj),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _bolumBasligi(String baslik, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Icon(ikon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            baslik,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sayiAlani(
    String etiket,
    TextEditingController ctrl, {
    String? yardimMetni,
    double? min,
    double? max,
    bool zorunlu = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: etiket,
          border: const OutlineInputBorder(),
          helperText: yardimMetni,
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) {
          if (v == null || v.isEmpty) return zorunlu ? 'Zorunlu alan' : null;
          final sayi = double.tryParse(v);
          if (sayi == null) return 'Geçerli bir sayı girin';
          if (min != null && sayi < min) return 'Min: $min';
          if (max != null && sayi > max) return 'Max: $max';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Boyutlandırma Asistanı'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: _yukleniyor
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Firebase\'den motor verileri alınıyor...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _bolumBasligi('Görev Profili', Icons.timeline),
                    _sayiAlani(
                      'Sürekli Tork — T_cont (Nm)',
                      _surekliTorkCtrl,
                      min: 0.1,
                    ),
                    _sayiAlani(
                      'Maksimum Tork — T_max (Nm)',
                      _tepeTorkCtrl,
                      min: 0.1,
                    ),
                    _sayiAlani(
                      'Toplam Çevrim Süresi — t_cycle (sn)',
                      _cevrimSuresiCtrl,
                      min: 0.1,
                      yardimMetni: 'Termal hesaplamalar için zorunlu',
                    ),
                    _sayiAlani(
                      'Maksimum Tork Süresi — t_max (sn)',
                      _tepeSuresiCtrl,
                      min: 0.01,
                    ),
                    _sayiAlani(
                      'Gerekli Güç — P (kW) (Opsiyonel)',
                      _gucCtrl,
                      min: 0.01,
                      zorunlu: false,
                      yardimMetni:
                          'Boş bırakılırsa tork ve hızdan otomatik hesaplanır',
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          _yukTarafi
                              ? 'Referans: YÜK TARAFI'
                              : 'Referans: MOTOR TARAFI',
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Tork ve hız değerleri hangi mile ait?',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _yukTarafi,
                        onChanged: (v) => setState(() => _yukTarafi = v),
                        dense: true,
                      ),
                    ),
                    _bolumBasligi('Hız Bilgileri', Icons.speed),
                    _sayiAlani(
                      'Nominal Hız — n_nom (rpm)',
                      _nominalHizCtrl,
                      min: 1,
                    ),
                    _sayiAlani(
                      'Maksimum Hız — n_max (rpm)',
                      _maxHizCtrl,
                      min: 1,
                      yardimMetni: 'Sürücü seçimi için gerekli',
                    ),
                    _bolumBasligi('Sistem Koşulları', Icons.settings),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: _beslemeTipi,
                        decoration: const InputDecoration(
                          labelText: 'Besleme Tipi',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'DC', child: Text('DC')),
                          DropdownMenuItem(
                            value: 'AC_tek_faz',
                            child: Text('Tek Faz'),
                          ),
                          DropdownMenuItem(
                            value: 'AC_uc_faz',
                            child: Text('Üç Faz'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _beslemeTipi = v!),
                      ),
                    ),
                    _sayiAlani(
                      'Ortam Sıcaklığı — T_amb (°C)',
                      _ortamSicCtrl,
                      min: -20,
                      max: 60,
                      yardimMetni: '>40°C → derating uyarısı',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: _motorSinifi,
                        decoration: const InputDecoration(
                          labelText: 'Motor Sınıfı',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'tumu', child: Text('Tümü')),
                          DropdownMenuItem(
                            value: 'servo',
                            child: Text('Servo'),
                          ),
                          DropdownMenuItem(
                            value: 'asenkron',
                            child: Text('Asenkron'),
                          ),
                          DropdownMenuItem(value: 'bldc', child: Text('BLDC')),
                          DropdownMenuItem(value: 'step', child: Text('Step')),
                        ],
                        onChanged: (v) => setState(() => _motorSinifi = v!),
                      ),
                    ),
                    _bolumBasligi(
                      'Mekanik Aktarım',
                      Icons.settings_input_component,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Redüktör kullanılıyor',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _reduktorVar,
                      onChanged: (v) => setState(() => _reduktorVar = v),
                      dense: true,
                    ),
                    if (_reduktorVar) ...[
                      const SizedBox(height: 8),
                      _sayiAlani(
                        'Redüksiyon Oranı — i',
                        _reduktorOraniCtrl,
                        min: 1,
                      ),
                      _sayiAlani(
                        'Mekanik Verim — η (0.0–1.0)',
                        _mekanikVerimCtrl,
                        min: 0.1,
                        max: 1.0,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _sayiAlani(
                      'Güvenlik Katsayısı — SF',
                      _guvenlikCtrl,
                      min: 1.0,
                      max: 3.0,
                      yardimMetni: 'Tipik değer: 1.25',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _hesaplaVeOner,
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'HESAPLA VE MOTOR ÖNER',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _surekliTorkCtrl.dispose();
    _tepeTorkCtrl.dispose();
    _cevrimSuresiCtrl.dispose();
    _tepeSuresiCtrl.dispose();
    _gucCtrl.dispose();
    _nominalHizCtrl.dispose();
    _maxHizCtrl.dispose();
    _ortamSicCtrl.dispose();
    _reduktorOraniCtrl.dispose();
    _mekanikVerimCtrl.dispose();
    _guvenlikCtrl.dispose();
    super.dispose();
  }
}
