# Motor Boyutlandırma Asistanı — Kurulum Talimatları

## Görevin
Bu dosyadaki talimatları sırayla uygula. Her adımı tamamladıktan sonra bir sonrakine geç.

---

## ADIM 1: Klasör yapısını oluştur

```
lib/models/
lib/services/
lib/screens/
```

---

## ADIM 2: Dosyaları yaz

Aşağıdaki her dosyayı belirtilen yola kaydet. Mevcut dosyaların üzerine yaz.

---

### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/giris_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MotorAsistaniApp());
}

class MotorAsistaniApp extends StatelessWidget {
  const MotorAsistaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motor Boyutlandırma Asistanı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GirisEkrani(),
    );
  }
}
```

---

### lib/models/motor_model.dart

```dart
class MotorModel {
  final String motorId;
  final String modelAdi;
  final String uretici;
  final String motorSinifi;
  final String verimSinifi;
  final double nominalTorkNm;
  final double maxTorkNm;
  final double nominalHizRpm;
  final double maxHizRpm;
  final double nominalGucKw;
  final double nominalAkimA;
  final double nominalGerilimV;

  MotorModel({
    required this.motorId,
    required this.modelAdi,
    required this.uretici,
    required this.motorSinifi,
    required this.verimSinifi,
    required this.nominalTorkNm,
    required this.maxTorkNm,
    required this.nominalHizRpm,
    required this.maxHizRpm,
    required this.nominalGucKw,
    required this.nominalAkimA,
    required this.nominalGerilimV,
  });

  factory MotorModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MotorModel(
      motorId: id,
      modelAdi: map['model_adi'] ?? '',
      uretici: map['uretici'] ?? '',
      motorSinifi: map['motor_sinifi'] ?? 'asenkron',
      verimSinifi: map['verim_sinifi'] ?? 'IE3',
      nominalTorkNm: (map['nominal_tork_Nm'] ?? 0).toDouble(),
      maxTorkNm: (map['max_tork_Nm'] ?? 0).toDouble(),
      nominalHizRpm: (map['nominal_hiz_rpm'] ?? 0).toDouble(),
      maxHizRpm: (map['max_hiz_rpm'] ?? 0).toDouble(),
      nominalGucKw: (map['nominal_guc_kW'] ?? 0).toDouble(),
      nominalAkimA: (map['nominal_akim_A'] ?? 0).toDouble(),
      nominalGerilimV: (map['nominal_gerilim_V'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model_adi': modelAdi,
      'uretici': uretici,
      'motor_sinifi': motorSinifi,
      'verim_sinifi': verimSinifi,
      'nominal_tork_Nm': nominalTorkNm,
      'max_tork_Nm': maxTorkNm,
      'nominal_hiz_rpm': nominalHizRpm,
      'max_hiz_rpm': maxHizRpm,
      'nominal_guc_kW': nominalGucKw,
      'nominal_akim_A': nominalAkimA,
      'nominal_gerilim_V': nominalGerilimV,
    };
  }
}
```

---

### lib/models/giris_parametreleri.dart

```dart
class GirisParametreleri {
  final double surekliTorkNm;
  final double tepeTorkNm;
  final double cevrimSuresiSn;
  final double tepeSuresiSn;
  final bool yukTarafi;
  final double nominalHizRpm;
  final double maxHizRpm;
  final String beslemetipi;
  final double ortamSicakligiC;
  final String motorSinifi;
  final bool reduktorVar;
  final double reduktorOrani;
  final double mekanikVerim;
  final double guvenlikKatsayisi;

  GirisParametreleri({
    required this.surekliTorkNm,
    required this.tepeTorkNm,
    required this.cevrimSuresiSn,
    required this.tepeSuresiSn,
    required this.yukTarafi,
    required this.nominalHizRpm,
    required this.maxHizRpm,
    required this.beslemetipi,
    required this.ortamSicakligiC,
    required this.motorSinifi,
    required this.reduktorVar,
    required this.reduktorOrani,
    required this.mekanikVerim,
    required this.guvenlikKatsayisi,
  });
}
```

---

### lib/models/oneri_sonucu.dart

```dart
import 'motor_model.dart';

class OneriSonucu {
  final MotorModel motor;
  final double puan;
  final double torkMarjiYuzde;
  final double hizMarjiYuzde;
  final List<String> avantajlar;
  final List<String> uyarilar;

  OneriSonucu({
    required this.motor,
    required this.puan,
    required this.torkMarjiYuzde,
    required this.hizMarjiYuzde,
    required this.avantajlar,
    required this.uyarilar,
  });
}

class IhtiyacOzeti {
  final double motorTarafiSurekliTorkNm;
  final double motorTarafiTepeTorkNm;
  final double motorTarafiMaxHizRpm;
  final double rmsTorkNm;
  final double guvenlikliTorkNm;
  final double ortalamaGucKw;

  IhtiyacOzeti({
    required this.motorTarafiSurekliTorkNm,
    required this.motorTarafiTepeTorkNm,
    required this.motorTarafiMaxHizRpm,
    required this.rmsTorkNm,
    required this.guvenlikliTorkNm,
    required this.ortalamaGucKw,
  });
}

class HesaplamaRaporu {
  final IhtiyacOzeti ihtiyacOzeti;
  final List<OneriSonucu> oneriler;
  final List<ElenmeNedeni> elenenMotorlar;

  HesaplamaRaporu({
    required this.ihtiyacOzeti,
    required this.oneriler,
    required this.elenenMotorlar,
  });
}

class ElenmeNedeni {
  final MotorModel motor;
  final String neden;

  ElenmeNedeni({required this.motor, required this.neden});
}
```

---

### lib/services/hesaplama_motoru.dart

```dart
import 'dart:math';
import '../models/giris_parametreleri.dart';
import '../models/motor_model.dart';
import '../models/oneri_sonucu.dart';

class HesaplamaMotoru {
  static double motorTarafiTork(
    double yukTarafiTorkNm,
    double reduktorOrani,
    double mekanikVerim,
  ) {
    if (reduktorOrani <= 0 || mekanikVerim <= 0) return yukTarafiTorkNm;
    return yukTarafiTorkNm / (reduktorOrani * mekanikVerim);
  }

  static double motorTarafiHiz(double yukHizRpm, double reduktorOrani) {
    if (reduktorOrani <= 0) return yukHizRpm;
    return yukHizRpm * reduktorOrani;
  }

  static double rmsTork(
    double tepeTorkNm,
    double surekliTorkNm,
    double tepeSuresiSn,
    double cevrimSuresiSn,
  ) {
    if (cevrimSuresiSn <= 0) return tepeTorkNm;
    final tOff = cevrimSuresiSn - tepeSuresiSn;
    if (tOff < 0) return tepeTorkNm;
    final rmsSq =
        (pow(tepeTorkNm, 2) * tepeSuresiSn + pow(surekliTorkNm, 2) * tOff) /
        cevrimSuresiSn;
    return sqrt(rmsSq);
  }

  static double guvenlikliTork(double torkNm, double guvenlikKatsayisi) {
    return torkNm * guvenlikKatsayisi;
  }

  static double ortalamaGuc(double rmsTorkNm, double nominalHizRpm) {
    return (rmsTorkNm * nominalHizRpm * 2 * pi / 60) / 1000;
  }

  static IhtiyacOzeti ihtiyacHesapla(GirisParametreleri p) {
    final double motorSurekliTork = p.yukTarafi
        ? motorTarafiTork(p.surekliTorkNm, p.reduktorOrani, p.mekanikVerim)
        : p.surekliTorkNm;

    final double motorTepeTork = p.yukTarafi
        ? motorTarafiTork(p.tepeTorkNm, p.reduktorOrani, p.mekanikVerim)
        : p.tepeTorkNm;

    final double motorMaxHiz = p.yukTarafi
        ? motorTarafiHiz(p.maxHizRpm, p.reduktorOrani)
        : p.maxHizRpm;

    final double motorNomHiz = p.yukTarafi
        ? motorTarafiHiz(p.nominalHizRpm, p.reduktorOrani)
        : p.nominalHizRpm;

    final double rms = rmsTork(
      motorTepeTork,
      motorSurekliTork,
      p.tepeSuresiSn,
      p.cevrimSuresiSn,
    );

    final double guvenlikliT = guvenlikliTork(rms, p.guvenlikKatsayisi);
    final double ortGuc = ortalamaGuc(rms, motorNomHiz);

    return IhtiyacOzeti(
      motorTarafiSurekliTorkNm: motorSurekliTork,
      motorTarafiTepeTorkNm: motorTepeTork,
      motorTarafiMaxHizRpm: motorMaxHiz,
      rmsTorkNm: rms,
      guvenlikliTorkNm: guvenlikliT,
      ortalamaGucKw: ortGuc,
    );
  }

  static String? _kontrol(MotorModel motor, IhtiyacOzeti ihtiyac, double ortamC) {
    if (motor.nominalTorkNm < ihtiyac.guvenlikliTorkNm) {
      return 'Sürekli tork kapasitesi yetersiz '
          '(${motor.nominalTorkNm.toStringAsFixed(1)} Nm < '
          '${ihtiyac.guvenlikliTorkNm.toStringAsFixed(1)} Nm gerekli)';
    }
    if (motor.maxTorkNm < ihtiyac.motorTarafiTepeTorkNm) {
      return 'Tepe tork kapasitesi yetersiz '
          '(${motor.maxTorkNm.toStringAsFixed(1)} Nm < '
          '${ihtiyac.motorTarafiTepeTorkNm.toStringAsFixed(1)} Nm gerekli)';
    }
    if (motor.maxHizRpm < ihtiyac.motorTarafiMaxHizRpm) {
      return 'Maksimum hız yetersiz '
          '(${motor.maxHizRpm.toStringAsFixed(0)} rpm < '
          '${ihtiyac.motorTarafiMaxHizRpm.toStringAsFixed(0)} rpm gerekli)';
    }
    if (ortamC > 40) {
      return 'Ortam sıcaklığı ${ortamC.toStringAsFixed(0)}°C — derating gerektirir';
    }
    return null;
  }

  static double _puanla(MotorModel motor, IhtiyacOzeti ihtiyac) {
    double puan = 0;

    final torkMarji =
        (motor.nominalTorkNm - ihtiyac.guvenlikliTorkNm) /
        ihtiyac.guvenlikliTorkNm;
    if (torkMarji >= 0.10 && torkMarji <= 0.30) {
      puan += 40;
    } else if (torkMarji < 0.10) {
      puan += 30;
    } else if (torkMarji <= 0.60) {
      puan += 20;
    } else {
      puan += 5;
    }

    final hizMarji =
        (motor.maxHizRpm - ihtiyac.motorTarafiMaxHizRpm) /
        ihtiyac.motorTarafiMaxHizRpm;
    if (hizMarji >= 0.05 && hizMarji <= 0.30) {
      puan += 20;
    } else if (hizMarji < 0.05) {
      puan += 12;
    } else if (hizMarji <= 0.60) {
      puan += 10;
    } else {
      puan += 3;
    }

    switch (motor.verimSinifi) {
      case 'IE4':
        puan += 25;
        break;
      case 'IE3':
        puan += 18;
        break;
      case 'IE2':
        puan += 8;
        break;
      default:
        puan += 5;
    }

    final gucFarki = (motor.nominalGucKw - ihtiyac.ortalamaGucKw).abs() /
        (ihtiyac.ortalamaGucKw + 0.001);
    if (gucFarki <= 0.20) {
      puan += 15;
    } else if (gucFarki <= 0.50) {
      puan += 8;
    } else {
      puan += 2;
    }

    return puan.clamp(0, 100);
  }

  static HesaplamaRaporu hesaplaVeOner(
    GirisParametreleri giris,
    List<MotorModel> motorListesi,
  ) {
    final ihtiyac = ihtiyacHesapla(giris);
    final List<OneriSonucu> oneriler = [];
    final List<ElenmeNedeni> elenenler = [];

    for (final motor in motorListesi) {
      if (giris.motorSinifi != 'tumu' &&
          motor.motorSinifi != giris.motorSinifi) {
        elenenler.add(ElenmeNedeni(
          motor: motor,
          neden: 'Motor sınıfı uyumsuz '
              '(istenen: ${giris.motorSinifi}, katalog: ${motor.motorSinifi})',
        ));
        continue;
      }

      final neden = _kontrol(motor, ihtiyac, giris.ortamSicakligiC);
      if (neden != null) {
        elenenler.add(ElenmeNedeni(motor: motor, neden: neden));
        continue;
      }

      final puan = _puanla(motor, ihtiyac);
      final torkMarji = ((motor.nominalTorkNm - ihtiyac.guvenlikliTorkNm) /
              ihtiyac.guvenlikliTorkNm * 100).toDouble();
      final hizMarji = ((motor.maxHizRpm - ihtiyac.motorTarafiMaxHizRpm) /
              ihtiyac.motorTarafiMaxHizRpm * 100).toDouble();

      final avantajlar = <String>[];
      final uyarilar = <String>[];

      if (motor.verimSinifi == 'IE4') avantajlar.add('Yüksek verim sınıfı (IE4)');
      if (motor.verimSinifi == 'IE3') avantajlar.add('İyi verim sınıfı (IE3)');
      if (torkMarji >= 10 && torkMarji <= 30) {
        avantajlar.add('Tork marjı ideal (%${torkMarji.toStringAsFixed(0)})');
      }
      if (torkMarji > 60) uyarilar.add('Oversizing riski — tork %${torkMarji.toStringAsFixed(0)} fazla');
      if (giris.ortamSicakligiC > 35) uyarilar.add('Sıcak ortam — soğutmaya dikkat');

      oneriler.add(OneriSonucu(
        motor: motor,
        puan: puan,
        torkMarjiYuzde: torkMarji,
        hizMarjiYuzde: hizMarji,
        avantajlar: avantajlar,
        uyarilar: uyarilar,
      ));
    }

    oneriler.sort((a, b) => b.puan.compareTo(a.puan));

    return HesaplamaRaporu(
      ihtiyacOzeti: ihtiyac,
      oneriler: oneriler,
      elenenMotorlar: elenenler,
    );
  }
}
```

---

### lib/services/firebase_servis.dart

```dart
import 'package:firebase_database/firebase_database.dart';
import '../models/motor_model.dart';

class FirebaseServis {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  static Future<List<MotorModel>> motorlariGetir() async {
    try {
      final ref = _db.ref('motors');
      final snapshot = await ref.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Sunucu bağlantı zaman aşımı (10s)'),
      );

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<MotorModel> motorlar = [];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          try {
            motorlar.add(MotorModel.fromMap(key.toString(), value));
          } catch (e) {
            print('Motor parse hatası ($key): $e');
          }
        }
      });

      return motorlar;
    } on Exception catch (e) {
      print('Firebase motorlariGetir hatası: $e');
      rethrow;
    }
  }

  static Future<void> geriBildirimKaydet({
    required String secilenMotorId,
    required double memnuniyetPuani,
    required bool isinmaSorunu,
    required bool performansSorunu,
    required Map<String, dynamic> girisParametreleri,
  }) async {
    try {
      final ref = _db.ref('geri_bildirimler').push();
      await ref.set({
        'secilen_motor_id': secilenMotorId,
        'memnuniyet_puani': memnuniyetPuani,
        'isinma_sorunu': isinmaSorunu,
        'performans_sorunu': performansSorunu,
        'giris_parametreleri': girisParametreleri,
        'tarih': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Firebase geriBildirimKaydet hatası: $e');
      rethrow;
    }
  }

  static Future<void> ornekMotorlariYukle() async {
    final ornekler = [
      {
        'model_adi': 'Siemens 1FK7-G2',
        'uretici': 'Siemens',
        'motor_sinifi': 'servo',
        'verim_sinifi': 'IE4',
        'nominal_tork_Nm': 8.0,
        'max_tork_Nm': 24.0,
        'nominal_hiz_rpm': 3000.0,
        'max_hiz_rpm': 6000.0,
        'nominal_guc_kW': 2.5,
        'nominal_akim_A': 7.5,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'Siemens 1LE1001 5.5kW',
        'uretici': 'Siemens',
        'motor_sinifi': 'asenkron',
        'verim_sinifi': 'IE3',
        'nominal_tork_Nm': 35.0,
        'max_tork_Nm': 84.0,
        'nominal_hiz_rpm': 1460.0,
        'max_hiz_rpm': 3000.0,
        'nominal_guc_kW': 5.5,
        'nominal_akim_A': 11.3,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'ABB M2BAX 7.5kW IE3',
        'uretici': 'ABB',
        'motor_sinifi': 'asenkron',
        'verim_sinifi': 'IE3',
        'nominal_tork_Nm': 49.0,
        'max_tork_Nm': 118.0,
        'nominal_hiz_rpm': 1460.0,
        'max_hiz_rpm': 3000.0,
        'nominal_guc_kW': 7.5,
        'nominal_akim_A': 14.8,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'ABB M2BAX 11kW IE4',
        'uretici': 'ABB',
        'motor_sinifi': 'asenkron',
        'verim_sinifi': 'IE4',
        'nominal_tork_Nm': 72.0,
        'max_tork_Nm': 173.0,
        'nominal_hiz_rpm': 1460.0,
        'max_hiz_rpm': 3000.0,
        'nominal_guc_kW': 11.0,
        'nominal_akim_A': 21.0,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'WEG W22 3kW IE3',
        'uretici': 'WEG',
        'motor_sinifi': 'asenkron',
        'verim_sinifi': 'IE3',
        'nominal_tork_Nm': 19.5,
        'max_tork_Nm': 46.8,
        'nominal_hiz_rpm': 1460.0,
        'max_hiz_rpm': 3000.0,
        'nominal_guc_kW': 3.0,
        'nominal_akim_A': 6.3,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'WEG W22 15kW IE4',
        'uretici': 'WEG',
        'motor_sinifi': 'asenkron',
        'verim_sinifi': 'IE4',
        'nominal_tork_Nm': 98.0,
        'max_tork_Nm': 235.0,
        'nominal_hiz_rpm': 1460.0,
        'max_hiz_rpm': 3000.0,
        'nominal_guc_kW': 15.0,
        'nominal_akim_A': 28.0,
        'nominal_gerilim_V': 400.0,
      },
      {
        'model_adi': 'Siemens 1FK7 High Speed',
        'uretici': 'Siemens',
        'motor_sinifi': 'servo',
        'verim_sinifi': 'IE4',
        'nominal_tork_Nm': 12.0,
        'max_tork_Nm': 36.0,
        'nominal_hiz_rpm': 4500.0,
        'max_hiz_rpm': 8000.0,
        'nominal_guc_kW': 5.0,
        'nominal_akim_A': 10.0,
        'nominal_gerilim_V': 400.0,
      },
    ];

    final ref = _db.ref('motors');
    for (int i = 0; i < ornekler.length; i++) {
      await ref.child('motor_${(i + 1).toString().padLeft(3, '0')}').set(ornekler[i]);
    }
    print('${ornekler.length} örnek motor Firebase\'e yüklendi.');
  }
}
```

---

### lib/screens/giris_ekrani.dart

```dart
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
        reduktorOrani: _reduktorVar ? double.parse(_reduktorOraniCtrl.text) : 1.0,
        mekanikVerim: _reduktorVar ? double.parse(_mekanikVerimCtrl.text) : 1.0,
        guvenlikKatsayisi: double.parse(_guvenlikCtrl.text),
      );

      final rapor = HesaplamaMotoru.hesaplaVeOner(giris, motorlar);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SonucEkrani(
            rapor: rapor,
            girisParametreleri: giris,
          ),
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
          Text(baslik,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blue.shade800)),
        ],
      ),
    );
  }

  Widget _sayiAlani(String etiket, TextEditingController ctrl,
      {String? yardimMetni, double? min, double? max}) {
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
          if (v == null || v.isEmpty) return 'Zorunlu alan';
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
                    _sayiAlani('Sürekli Tork — T_cont (Nm)', _surekliTorkCtrl, min: 0.1),
                    _sayiAlani('Tepe Tork — T_peak (Nm)', _tepeTorkCtrl, min: 0.1),
                    _sayiAlani('Toplam Çevrim Süresi — t_cycle (sn)', _cevrimSuresiCtrl,
                        min: 0.1, yardimMetni: 'Termal hesaplamalar için zorunlu'),
                    _sayiAlani('Tepe Tork Süresi — t_peak (sn)', _tepeSuresiCtrl, min: 0.01),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5)),
                      child: SwitchListTile(
                        title: Text(_yukTarafi
                            ? 'Referans: YÜK TARAFI'
                            : 'Referans: MOTOR TARAFI',
                            style: const TextStyle(fontSize: 14)),
                        subtitle: const Text('Tork ve hız değerleri hangi mile ait?',
                            style: TextStyle(fontSize: 12)),
                        value: _yukTarafi,
                        onChanged: (v) => setState(() => _yukTarafi = v),
                        dense: true,
                      ),
                    ),
                    _bolumBasligi('Hız Bilgileri', Icons.speed),
                    _sayiAlani('Nominal Hız — n_nom (rpm)', _nominalHizCtrl, min: 1),
                    _sayiAlani('Maksimum Hız — n_max (rpm)', _maxHizCtrl,
                        min: 1, yardimMetni: 'Sürücü seçimi için gerekli'),
                    _bolumBasligi('Sistem Koşulları', Icons.settings),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: _beslemeTipi,
                        decoration: const InputDecoration(
                            labelText: 'Besleme Tipi',
                            border: OutlineInputBorder(),
                            isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'DC', child: Text('DC')),
                          DropdownMenuItem(value: 'AC_tek_faz', child: Text('AC Tek Faz')),
                          DropdownMenuItem(value: 'AC_uc_faz', child: Text('AC Üç Faz')),
                        ],
                        onChanged: (v) => setState(() => _beslemeTipi = v!),
                      ),
                    ),
                    _sayiAlani('Ortam Sıcaklığı — T_amb (°C)', _ortamSicCtrl,
                        min: -20, max: 60, yardimMetni: '>40°C → derating uyarısı'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: _motorSinifi,
                        decoration: const InputDecoration(
                            labelText: 'Motor Sınıfı',
                            border: OutlineInputBorder(),
                            isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'tumu', child: Text('Tümü')),
                          DropdownMenuItem(value: 'servo', child: Text('Servo')),
                          DropdownMenuItem(value: 'asenkron', child: Text('Asenkron')),
                          DropdownMenuItem(value: 'bldc', child: Text('BLDC')),
                          DropdownMenuItem(value: 'step', child: Text('Step')),
                        ],
                        onChanged: (v) => setState(() => _motorSinifi = v!),
                      ),
                    ),
                    _bolumBasligi('Mekanik Aktarım', Icons.settings_input_component),
                    SwitchListTile(
                      title: const Text('Redüktör kullanılıyor',
                          style: TextStyle(fontSize: 14)),
                      value: _reduktorVar,
                      onChanged: (v) => setState(() => _reduktorVar = v),
                      dense: true,
                    ),
                    if (_reduktorVar) ...[
                      const SizedBox(height: 8),
                      _sayiAlani('Redüksiyon Oranı — i', _reduktorOraniCtrl, min: 1),
                      _sayiAlani('Mekanik Verim — η (0.0–1.0)', _mekanikVerimCtrl,
                          min: 0.1, max: 1.0),
                    ],
                    const SizedBox(height: 8),
                    _sayiAlani('Güvenlik Katsayısı — SF', _guvenlikCtrl,
                        min: 1.0, max: 3.0, yardimMetni: 'Tipik değer: 1.25'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _hesaplaVeOner,
                      icon: const Icon(Icons.search),
                      label: const Text('HESAPLA VE MOTOR ÖNER',
                          style: TextStyle(fontSize: 16)),
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
    _nominalHizCtrl.dispose();
    _maxHizCtrl.dispose();
    _ortamSicCtrl.dispose();
    _reduktorOraniCtrl.dispose();
    _mekanikVerimCtrl.dispose();
    _guvenlikCtrl.dispose();
    super.dispose();
  }
}
```

---

### lib/screens/sonuc_ekrani.dart

```dart
import 'package:flutter/material.dart';
import '../models/oneri_sonucu.dart';
import '../models/motor_model.dart';
import '../services/firebase_servis.dart';
import '../models/giris_parametreleri.dart';

class SonucEkrani extends StatefulWidget {
  final HesaplamaRaporu rapor;
  final GirisParametreleri girisParametreleri;

  const SonucEkrani({
    super.key,
    required this.rapor,
    required this.girisParametreleri,
  });

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani> {
  bool _elenenlerGosteriliyor = false;
  double _memnuniyetPuani = 4;
  bool _isinmaSorunu = false;
  bool _performansSorunu = false;

  Widget _ihtiyacOzeti() {
    final o = widget.rapor.ihtiyacOzeti;
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.analytics, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text('Motor Tarafı İhtiyaç Özeti',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue.shade800)),
            ]),
            const Divider(),
            _ozetSatiri('Sürekli Tork (güvenlikli)',
                '${o.guvenlikliTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('RMS Tork', '${o.rmsTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('Tepe Tork (motor tarafı)',
                '${o.motorTarafiTepeTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('Maksimum Hız (motor tarafı)',
                '${o.motorTarafiMaxHizRpm.toStringAsFixed(0)} rpm'),
            _ozetSatiri('Ortalama Güç', '${o.ortalamaGucKw.toStringAsFixed(2)} kW'),
          ],
        ),
      ),
    );
  }

  Widget _ozetSatiri(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(deger,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _motorKarti(OneriSonucu oneri, int sira) {
    final motor = oneri.motor;
    final Color puanRengi = oneri.puan >= 70
        ? Colors.green.shade700
        : oneri.puan >= 45
            ? Colors.orange.shade700
            : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor:
                    sira == 0 ? Colors.amber.shade100 : Colors.grey.shade100,
                child: Text('${sira + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sira == 0
                            ? Colors.amber.shade800
                            : Colors.grey.shade600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(motor.modelAdi,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                        '${motor.uretici} · ${motor.motorSinifi} · ${motor.verimSinifi}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: puanRengi.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: puanRengi.withOpacity(0.4)),
                ),
                child: Text('${oneri.puan.toStringAsFixed(0)} puan',
                    style: TextStyle(
                        color: puanRengi,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _bilgeChip(
                    '${motor.nominalTorkNm}/${motor.maxTorkNm} Nm',
                    'nom/maks tork'),
                _bilgeChip('${motor.maxHizRpm.toStringAsFixed(0)} rpm', 'maks hız'),
                _bilgeChip('${motor.nominalGucKw} kW', 'güç'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _marjChip('Tork marjı', oneri.torkMarjiYuzde),
                _marjChip('Hız marjı', oneri.hizMarjiYuzde),
              ],
            ),
            if (oneri.avantajlar.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...oneri.avantajlar.map((a) => _bilgiSatiri(a, true)),
            ],
            if (oneri.uyarilar.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...oneri.uyarilar.map((u) => _bilgiSatiri(u, false)),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _geriBildirimDialog(motor),
              icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
              label: const Text('Bu motoru seçtim',
                  style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgeChip(String deger, String etiket) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(deger,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(etiket,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _marjChip(String etiket, double yuzde) {
    final renk = yuzde >= 10 && yuzde <= 35
        ? Colors.green
        : yuzde < 5
            ? Colors.orange
            : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: renk.shade200),
      ),
      child: Text('+${yuzde.toStringAsFixed(0)}% $etiket',
          style: TextStyle(fontSize: 11, color: renk.shade700)),
    );
  }

  Widget _bilgiSatiri(String metin, bool avantaj) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(children: [
        Icon(
            avantaj
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 14,
            color: avantaj ? Colors.green.shade600 : Colors.orange.shade700),
        const SizedBox(width: 5),
        Expanded(
            child: Text(metin,
                style: TextStyle(
                    fontSize: 12,
                    color: avantaj
                        ? Colors.green.shade700
                        : Colors.orange.shade800))),
      ]),
    );
  }

  void _geriBildirimDialog(MotorModel motor) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Geri Bildirim — ${motor.modelAdi}',
              style: const TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Memnuniyet (1–5):', style: TextStyle(fontSize: 13)),
              Slider(
                value: _memnuniyetPuani,
                min: 1,
                max: 5,
                divisions: 4,
                label: _memnuniyetPuani.toStringAsFixed(0),
                onChanged: (v) =>
                    setDialogState(() => _memnuniyetPuani = v),
              ),
              SwitchListTile(
                title: const Text('Isınma sorunu',
                    style: TextStyle(fontSize: 13)),
                value: _isinmaSorunu,
                onChanged: (v) =>
                    setDialogState(() => _isinmaSorunu = v),
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Performans sorunu',
                    style: TextStyle(fontSize: 13)),
                value: _performansSorunu,
                onChanged: (v) =>
                    setDialogState(() => _performansSorunu = v),
                dense: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await FirebaseServis.geriBildirimKaydet(
                    secilenMotorId: motor.motorId,
                    memnuniyetPuani: _memnuniyetPuani,
                    isinmaSorunu: _isinmaSorunu,
                    performansSorunu: _performansSorunu,
                    girisParametreleri: {
                      'sureklii_tork_Nm': widget.girisParametreleri.surekliTorkNm,
                      'tepe_tork_Nm': widget.girisParametreleri.tepeTorkNm,
                      'cevrim_suresi_sn': widget.girisParametreleri.cevrimSuresiSn,
                      'max_hiz_rpm': widget.girisParametreleri.maxHizRpm,
                      'motor_sinifi': widget.girisParametreleri.motorSinifi,
                    },
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Geri bildirim kaydedildi!'),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Kayıt hatası: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oneriler = widget.rapor.oneriler;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Önerileri'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ihtiyacOzeti(),
            const SizedBox(height: 16),
            if (oneriler.isEmpty)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Uygun motor bulunamadı. Parametreleri gözden geçiriniz.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              )
            else ...[
              Text('${oneriler.length} uygun motor bulundu',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...oneriler.asMap().entries.map((e) => _motorKarti(e.value, e.key)),
            ],
            if (widget.rapor.elenenMotorlar.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => setState(
                    () => _elenenlerGosteriliyor = !_elenenlerGosteriliyor),
                icon: Icon(
                    _elenenlerGosteriliyor
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18),
                label: Text(
                    'Elenen motorlar (${widget.rapor.elenenMotorlar.length})',
                    style: const TextStyle(fontSize: 13)),
              ),
              if (_elenenlerGosteriliyor)
                ...widget.rapor.elenenMotorlar.map(
                  (e) => Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined,
                          color: Colors.red.shade300, size: 20),
                      title: Text(e.motor.modelAdi,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(e.neden,
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### test/widget_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:motor_boyutlandirma_asistani/models/giris_parametreleri.dart';
import 'package:motor_boyutlandirma_asistani/models/motor_model.dart';
import 'package:motor_boyutlandirma_asistani/services/hesaplama_motoru.dart';

void main() {
  group('HesaplamaMotoru - Formül Testleri', () {
    test('RMS tork duty cycle 30%', () {
      final rms = HesaplamaMotoru.rmsTork(60.0, 20.0, 3.0, 10.0);
      expect(rms, closeTo(36.88, 0.5));
    });

    test('RMS tork duty cycle 100%', () {
      final rms = HesaplamaMotoru.rmsTork(60.0, 60.0, 10.0, 10.0);
      expect(rms, closeTo(60.0, 0.1));
    });

    test('Motor tarafı tork dönüşümü i=5 eta=0.95', () {
      final t = HesaplamaMotoru.motorTarafiTork(100.0, 5.0, 0.95);
      expect(t, closeTo(21.05, 0.1));
    });

    test('Motor tarafı hız dönüşümü i=5', () {
      final n = HesaplamaMotoru.motorTarafiHiz(300.0, 5.0);
      expect(n, closeTo(1500.0, 0.1));
    });

    test('Güvenlikli tork SF=1.25', () {
      final gt = HesaplamaMotoru.guvenlikliTork(40.0, 1.25);
      expect(gt, closeTo(50.0, 0.1));
    });
  });

  group('HesaplamaMotoru - Öneri Testleri', () {
    final giris = GirisParametreleri(
      surekliTorkNm: 20.0, tepeTorkNm: 50.0,
      cevrimSuresiSn: 10.0, tepeSuresiSn: 3.0,
      yukTarafi: true, nominalHizRpm: 1460.0, maxHizRpm: 2000.0,
      beslemetipi: 'AC_uc_faz', ortamSicakligiC: 25.0,
      motorSinifi: 'tumu', reduktorVar: false,
      reduktorOrani: 1.0, mekanikVerim: 1.0, guvenlikKatsayisi: 1.25,
    );

    final motorlar = [
      MotorModel(motorId: 't1', modelAdi: 'Küçük Motor', uretici: 'Test',
          motorSinifi: 'asenkron', verimSinifi: 'IE3',
          nominalTorkNm: 10.0, maxTorkNm: 25.0,
          nominalHizRpm: 1460.0, maxHizRpm: 3000.0,
          nominalGucKw: 1.5, nominalAkimA: 3.5, nominalGerilimV: 400.0),
      MotorModel(motorId: 't2', modelAdi: 'Uygun Motor', uretici: 'Test',
          motorSinifi: 'asenkron', verimSinifi: 'IE3',
          nominalTorkNm: 40.0, maxTorkNm: 96.0,
          nominalHizRpm: 1460.0, maxHizRpm: 3000.0,
          nominalGucKw: 5.5, nominalAkimA: 11.3, nominalGerilimV: 400.0),
    ];

    test('Küçük motor elenecek', () {
      final rapor = HesaplamaMotoru.hesaplaVeOner(giris, motorlar);
      final ids = rapor.elenenMotorlar.map((e) => e.motor.motorId).toList();
      expect(ids, contains('t1'));
    });

    test('En az 1 öneri dönmeli', () {
      final rapor = HesaplamaMotoru.hesaplaVeOner(giris, motorlar);
      expect(rapor.oneriler.length, greaterThanOrEqualTo(1));
    });
  });
}
```

---

## ADIM 3: pubspec.yaml bağımlılıklarını kontrol et

`pubspec.yaml` dosyasında `dependencies:` altında şunların olduğunu doğrula:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_database: ^11.1.4
  cupertino_icons: ^1.0.8
```

Eksikse ekle ve kaydet.

---

## ADIM 4: Terminalde çalıştır

```bash
flutter pub get
```

Hata yoksa:

```bash
flutter run
```

---

## ADIM 5: Firebase Rules güncelle

Firebase Console → Realtime Database → Rules sekmesi → şunu yapıştır ve Publish:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

---

## TAMAMLANDI
Tüm adımlar bittikten sonra uygulama çalışır durumda olacak.
