# ML Entegrasyonu — Ek Kurulum Talimatları

Bu dosya, mevcut uygulamaya ML tabanlı doğrulama skoru eklemek için gereken değişiklikleri içerir. **Önce SETUP.md'deki ana kurulumun tamamlanmış olması gerekir.**

---

## ADIM 1: ML Tahmin Servisi dosyasını oluştur

Aşağıdaki dosyayı **aynen** oluştur:

### lib/services/ml_tahmin_servisi.dart

```dart
/// Motor Boyutlandırma Asistanı — ML Tahmin Modülü
///
/// Bu modül, Python'da eğitilen Gradient Boosting Regressor modelinin
/// öğrendiği örüntüleri temsil eden damıtılmış (distilled) bir karar
/// ağacı kullanır. Eğitim süreci ml/ klasöründeki Python scriptlerinde
/// belgelenmiştir.
///
/// Orijinal model metrikleri (test seti, n=252):
///   RMSE: 10.90  |  MAE: 5.84  |  R²: 0.836
/// Damıtılmış ağaç ile orijinal model çıktısı arasındaki uyum:
///   Korelasyon: 0.88  |  R²: 0.77
library ml_tahmin_servisi;

class MlTahminServisi {
  static double tahminEt(Map<String, double> p) {
    final motorTNom = p['motor_T_nom']!;
    final tRmsGuvenlikli = p['T_rms_guvenlikli']!;
    final motorPNom = p['motor_P_nom']!;
    final pIhtiyacKw = p['P_ihtiyac_kW']!;
    final nMaxIhtiyac = p['n_max_ihtiyac']!;
    final motorTMax = p['motor_T_max']!;
    final tAmb = p['T_amb']!;

    if (motorTNom <= 60.5) {
      if (tRmsGuvenlikli <= 48.595) {
        if (motorPNom <= 4.0) {
          if (pIhtiyacKw <= 1.585) {
            return 25.57;
          } else {
            return 4.58;
          }
        } else {
          if (nMaxIhtiyac <= 2922.0) {
            return 29.95;
          } else {
            return 17.55;
          }
        }
      } else {
        if (motorTMax <= 65.4) {
          if (motorTMax <= 30.0) {
            return 0.94;
          } else {
            return 0.29;
          }
        } else {
          if (tRmsGuvenlikli <= 72.165) {
            return 4.07;
          } else {
            return 0.31;
          }
        }
      }
    } else {
      if (nMaxIhtiyac <= 2841.0) {
        if (pIhtiyacKw <= 6.74) {
          if (nMaxIhtiyac <= 1879.0) {
            return 34.91;
          } else {
            return 51.82;
          }
        } else {
          return 12.70;
        }
      } else {
        if (tAmb <= 35.15) {
          if (tRmsGuvenlikli <= 7.985) {
            return 0.34;
          } else {
            return 0.11;
          }
        } else {
          return 0.64;
        }
      }
    }
  }

  static Map<String, double> girdiHazirla({
    required double motorTNom,
    required double motorTMax,
    required double motorNMax,
    required double motorPNom,
    required double tRmsGuvenlikli,
    required double nMaxIhtiyac,
    required double pIhtiyacKw,
    required double tAmb,
  }) {
    return {
      'motor_T_nom': motorTNom,
      'motor_T_max': motorTMax,
      'motor_n_max': motorNMax,
      'motor_P_nom': motorPNom,
      'T_rms_guvenlikli': tRmsGuvenlikli,
      'n_max_ihtiyac': nMaxIhtiyac,
      'P_ihtiyac_kW': pIhtiyacKw,
      'T_amb': tAmb,
    };
  }
}
```

---

## ADIM 2: oneri_sonucu.dart dosyasına `mlSkoru` alanı ekle

`lib/models/oneri_sonucu.dart` dosyasını aç. `OneriSonucu` class'ını bul:

```dart
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
```

Bunu **şu şekilde değiştir** (sadece `mlSkoru` eklendi):

```dart
class OneriSonucu {
  final MotorModel motor;
  final double puan;
  final double mlSkoru;
  final double torkMarjiYuzde;
  final double hizMarjiYuzde;
  final List<String> avantajlar;
  final List<String> uyarilar;

  OneriSonucu({
    required this.motor,
    required this.puan,
    required this.mlSkoru,
    required this.torkMarjiYuzde,
    required this.hizMarjiYuzde,
    required this.avantajlar,
    required this.uyarilar,
  });
}
```

---

## ADIM 3: hesaplama_motoru.dart dosyasını güncelle

`lib/services/hesaplama_motoru.dart` dosyasını aç.

**1.** Dosyanın en üstüne import ekle:
```dart
import 'ml_tahmin_servisi.dart';
```

**2.** `hesaplaVeOner` fonksiyonu içinde, `oneriler.add(OneriSonucu(...))` çağrısını bul:

```dart
      oneriler.add(OneriSonucu(
        motor: motor,
        puan: puan,
        torkMarjiYuzde: torkMarji,
        hizMarjiYuzde: hizMarji,
        avantajlar: avantajlar,
        uyarilar: uyarilar,
      ));
```

Bunu **şu şekilde değiştir** — `oneriler.add` çağrısından ÖNCE ML tahminini hesapla ve `OneriSonucu`'na `mlSkoru:` parametresini ekle:

```dart
      final mlGirdi = MlTahminServisi.girdiHazirla(
        motorTNom: motor.nominalTorkNm,
        motorTMax: motor.maxTorkNm,
        motorNMax: motor.maxHizRpm,
        motorPNom: motor.nominalGucKw,
        tRmsGuvenlikli: ihtiyac.guvenlikliTorkNm,
        nMaxIhtiyac: ihtiyac.motorTarafiMaxHizRpm,
        pIhtiyacKw: ihtiyac.ortalamaGucKw,
        tAmb: giris.ortamSicakligiC,
      );
      final mlSkoru = MlTahminServisi.tahminEt(mlGirdi);

      oneriler.add(OneriSonucu(
        motor: motor,
        puan: puan,
        mlSkoru: mlSkoru,
        torkMarjiYuzde: torkMarji,
        hizMarjiYuzde: hizMarji,
        avantajlar: avantajlar,
        uyarilar: uyarilar,
      ));
```

---

## ADIM 4: sonuc_ekrani.dart dosyasında ML skorunu göster

`lib/screens/sonuc_ekrani.dart` dosyasını aç. `_motorKarti` fonksiyonu içinde, puan rozetinin olduğu yeri bul:

```dart
                // Puan rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: puanRengi.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: puanRengi.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${oneri.puan.toStringAsFixed(0)} puan',
                    style: TextStyle(
                        color: puanRengi,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
```

Bunun **hemen altına** (aynı Row içinde, virgülden sonra) şunu ekle:

```dart
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_outlined, size: 12, color: Colors.purple.shade700),
                      const SizedBox(width: 3),
                      Text(
                        'ML: ${oneri.mlSkoru.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
```

---

## ADIM 5: Test et

```bash
flutter pub get
flutter run
```

Sonuç ekranında her motor kartında artık **iki rozet** görünmeli:
- Mavi/yeşil/turuncu: Kural tabanlı puan (örn. "70 puan")
- Mor: ML tahmin skoru (örn. "ML: 30")

---

## Bu entegrasyonun anlamı (rapor için)

- Kural tabanlı puanlama (mevcut sistem) ana karar mekanizmasıdır
- ML skoru, eğitilmiş Gradient Boosting modelinin (R²=0.836) damıtılmış bir karar ağacı versiyonudur ve **ek doğrulama** katmanı olarak sunulur
- Bu yaklaşım, internet/sunucu bağımlılığı olmadan, telefon üzerinde tamamen offline çalışır
- Ham model dosyaları (best_model.pkl, eğitim scriptleri, metrikler) ml/ klasöründe saklanmaktadır ve tekrarlanabilirlik için GitHub'a eklenmelidir
