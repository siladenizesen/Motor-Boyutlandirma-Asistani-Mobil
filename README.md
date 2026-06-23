# Motor Boyutlandırma Asistanı 🔧⚡

**Yapay Zeka Destekli Elektrik Motoru Seçim Asistanı**

Bilgisayar Mühendisliği Bitirme Projesi — Sıla Deniz Esen

---

## 📱 Proje Hakkında

Motor Boyutlandırma Asistanı, endüstriyel uygulamalar için elektrik motoru seçimini otomatikleştiren bir Flutter mobil uygulamasıdır. Kullanıcının girdiği yük parametrelerine (tork, hız, çevrim süresi, ortam koşulları) göre:

- RMS tork ve termal yük hesaplar
- Katalogdaki motorları 4 mühendislik kısıtıyla filtreler
- Geçen motorları 0–100 puan arası bir algoritmaya göre sıralar
- Eğitilmiş bir makine öğrenmesi modelinden gelen ek doğrulama skoru sunar
- En uygun motoru gerekçesiyle önerir

---

## 🏗️ Mimari

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── models/
│   ├── motor_model.dart               # Motor veri modeli
│   ├── giris_parametreleri.dart       # 10 kullanıcı giriş parametresi
│   └── oneri_sonucu.dart              # Hesaplama raporu modelleri
├── services/
│   ├── hesaplama_motoru.dart          # RMS tork, filtreleme, puanlama
│   ├── firebase_servis.dart           # Firebase okuma/yazma
│   └── ml_tahmin_servisi.dart         # ML doğrulama skoru (damıtılmış model)
└── screens/
    ├── giris_ekrani.dart              # Parametlere giriş formu
    └── sonuc_ekrani.dart              # Motor önerileri ekranı

ml/
├── 01_veri_uretimi.py                 # Sentetik eğitim verisi üretimi (1260 kayıt)
├── 02_model_egitimi.py                # Model eğitimi ve karşılaştırma
├── 04_karar_agaci_damitma.py          # Mobil entegrasyon için model damıtma
├── best_model.pkl                     # Eğitilmiş Gradient Boosting modeli
└── motor_egitim_verisi.csv            # Eğitim veri seti
```

---

## ⚙️ Kullanılan Teknolojiler

| Teknoloji | Kullanım |
|-----------|----------|
| Flutter 3.x | Mobil uygulama geliştirme |
| Firebase Realtime Database | Motor kataloğu ve geri bildirim depolama |
| Dart | Hesaplama motoru ve iş mantığı |
| Python / scikit-learn | ML model eğitimi (çevrimdışı) |
| Android (API 33+) | Hedef platform |

---

## 🧮 Hesaplama Algoritması

### RMS Tork Formülü
```
T_rms = √ [ (T_peak² × t_peak + T_cont² × t_off) / t_cycle ]
```

### Redüktör Dönüşümü
```
T_motor = T_yuk / (i × η)
n_motor = n_yuk × i
```

### Hard Constraint Filtreleme (4 Kısıt)
| # | Kısıt | Koşul |
|---|-------|-------|
| K1 | Sürekli tork | motor.T_nom ≥ T_rms × SF |
| K2 | Tepe tork | motor.T_max ≥ T_peak |
| K3 | Maksimum hız | motor.n_max ≥ n_hedef |
| K4 | Termal kapasite | T_amb ≤ 40°C |

### Soft Scoring (0–100 Puan)
| Kriter | Max Puan |
|--------|----------|
| Tork marjı uyumu (%10–30 ideal) | 40 |
| Hız marjı uyumu (%5–30 ideal) | 20 |
| Verim sınıfı (IE4/IE3/IE2) | 25 |
| Güç boyutu uyumu (±%20 ideal) | 15 |

---

## 🤖 Makine Öğrenmesi Modülü

Kural tabanlı puanlamaya ek olarak, sentetik veriyle eğitilmiş bir regresyon modeli **ML doğrulama skoru** üretir.

### Eğitim Süreci

1. **Veri üretimi** (`ml/01_veri_uretimi.py`): 7 motor × 180 farklı yük senaryosu kombinasyonundan oluşan 1260 kayıtlık sentetik veri seti üretilir.
2. **Model eğitimi** (`ml/02_model_egitimi.py`): Lineer Regresyon, Random Forest ve Gradient Boosting algoritmaları karşılaştırılır.
3. **Mobil damıtma** (`ml/04_karar_agaci_damitma.py`): En iyi model (Gradient Boosting) doğrudan mobilde çalıştırılamayacak kadar büyük olduğundan, model çıktılarını öğrenen basit bir karar ağacına damıtılır. Bu ağaç `lib/services/ml_tahmin_servisi.dart` dosyasına if-else yapısı olarak gömülmüştür — internet/sunucu bağımlılığı yoktur.

### Model Performansı (Test Seti, n=252)

| Model | RMSE | MAE | R² |
|-------|------|-----|-----|
| Lineer Regresyon | 24.09 | 18.63 | 0.20 |
| Random Forest | 10.98 | 5.37 | 0.83 |
| **Gradient Boosting** | **10.90** | **5.84** | **0.84** |

Damıtılmış karar ağacı ile orijinal Gradient Boosting modelinin çıktıları arasındaki korelasyon: **0.88** (R²=0.77).

### En Önemli Özellikler (Feature Importance)

1. Güvenlikli RMS Tork — %27.6
2. Maksimum Hız İhtiyacı — %18.9
3. Motor Nominal Gücü — %9.0

ML eğitimini tekrar çalıştırmak için:
```bash
cd ml
pip install pandas numpy scikit-learn
python 01_veri_uretimi.py
python 02_model_egitimi.py
python 04_karar_agaci_damitma.py
```

---

## 🗄️ Firebase Veri Yapısı

```
motors/
  motor_001/
    model_adi: "Siemens 1FK7-G2"
    uretici: "Siemens"
    motor_sinifi: "servo"
    verim_sinifi: "IE4"
    nominal_tork_Nm: 8.0
    max_tork_Nm: 24.0
    nominal_hiz_rpm: 3000.0
    max_hiz_rpm: 6000.0
    nominal_guc_kW: 2.5
    ...

geri_bildirimler/
  -OuuymldDUB0ljJTyihd/
    secilen_motor_id: "motor_003"
    memnuniyet_puani: 4
    isinma_sorunu: false
    performans_sorunu: false
    tarih: "2026-06-12T11:38:03"
    giris_parametreleri: { ... }
```

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Android Studio veya VS Code
- Firebase projesi (google-services.json)

### Adımlar

```bash
# Repoyu klonla
git clone https://github.com/siladenizesen/Motor-Boyutlandirma-Asistani-Mobil.git
cd Motor-Boyutlandirma-Asistani-Mobil

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### Firebase Ayarı
1. Firebase Console → Realtime Database → Rules:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```
2. İlk çalıştırmada uygulama 7 örnek motoru otomatik yükler.

---

## 🧪 Test Senaryoları

Gerçek cihaz testleri (Xiaomi 11T Pro, Android 13) üzerinde doğrulanmıştır.

| Senaryo | T_cont | T_peak | t_cycle | n_max | SF | Sonuç |
|---------|--------|--------|---------|-------|-----|-------|
| Konveyör | 20 Nm | 50 Nm | 10s | 2000 rpm | 1.25 | 3 öneri, 1. = ABB 7.5kW IE3 (70p) |
| Pompa | 35 Nm | 70 Nm | 8s | 1500 rpm | 1.25 | 2 öneri, 1. = ABB 11kW IE4 (70p) |
| Asansör | 15 Nm | 100 Nm | 12s | 1800 rpm | 1.5 | 1 öneri = WEG 15kW IE4 (70p) |
| Termal Risk | 50 Nm | 150 Nm | 5s | 3000 rpm | 1.5 | Uygun motor bulunamadı |
| Redüktörlü | 80 Nm | 200 Nm | 10s | 300 rpm | 1.25 | Termal eleme (i=5, η=0.9) |

### Testleri Çalıştır
```bash
flutter test
```

---

## 📊 Motor Kataloğu

Uygulama 7 motor içermektedir:

| Model | Üretici | Sınıf | Nominal Tork | Max Hız | Verim |
|-------|---------|-------|-------------|---------|-------|
| Siemens 1FK7-G2 | Siemens | Servo | 8 Nm | 6000 rpm | IE4 |
| Siemens 1LE1001 5.5kW | Siemens | Asenkron | 35 Nm | 3000 rpm | IE3 |
| ABB M2BAX 7.5kW | ABB | Asenkron | 49 Nm | 3000 rpm | IE3 |
| ABB M2BAX 11kW | ABB | Asenkron | 72 Nm | 3000 rpm | IE4 |
| WEG W22 3kW | WEG | Asenkron | 19.5 Nm | 3000 rpm | IE3 |
| WEG W22 15kW | WEG | Asenkron | 98 Nm | 3000 rpm | IE4 |
| Siemens 1FK7 High Speed | Siemens | Servo | 12 Nm | 8000 rpm | IE4 |

---

## 📁 Proje Durumu

- [x] Flutter katmanlı mimari
- [x] Firebase Realtime Database entegrasyonu
- [x] 10 parametreli girdi formu
- [x] RMS tork hesaplama motoru
- [x] Hard constraint filtreleme
- [x] Soft scoring algoritması
- [x] Makine öğrenmesi modeli (Gradient Boosting, R²=0.84)
- [x] Mobil ML entegrasyonu (damıtılmış karar ağacı)
- [x] Kullanıcı geri bildirim sistemi
- [x] Gerçek cihaz testi (5 senaryo)
- [x] Unit testler
- [ ] APK release build

---

## 👩‍💻 Geliştirici

**Sıla Deniz Esen**  
Bilgisayar Mühendisliği Bitirme Projesi  
Haziran 2026
