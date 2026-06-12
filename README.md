# Motor Boyutlandırma Asistanı 🔧⚡

**Yapay Zeka Destekli Elektrik Motoru Seçim Asistanı**

Bilgisayar Mühendisliği Bitirme Projesi — Sıla Deniz Esen

---

## 📱 Proje Hakkında

Motor Boyutlandırma Asistanı, endüstriyel uygulamalar için elektrik motoru seçimini otomatikleştiren bir Flutter mobil uygulamasıdır. Kullanıcının girdiği yük parametrelerine (tork, hız, çevrim süresi, ortam koşulları) göre:

- RMS tork ve termal yük hesaplar
- Katalogdaki motorları 4 mühendislik kısıtıyla filtreler
- Geçen motorları 0–100 puan arası bir algoritmaya göre sıralar
- En uygun motoru gerekçesiyle önerir

---

## 🏗️ Mimari

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── models/
│   ├── motor_model.dart           # Motor veri modeli
│   ├── giris_parametreleri.dart   # 10 kullanıcı giriş parametresi
│   └── oneri_sonucu.dart          # Hesaplama raporu modelleri
├── services/
│   ├── hesaplama_motoru.dart      # RMS tork, filtreleme, puanlama
│   └── firebase_servis.dart       # Firebase okuma/yazma
└── screens/
    ├── giris_ekrani.dart          # Parametlere giriş formu
    └── sonuc_ekrani.dart          # Motor önerileri ekranı
```

---

## ⚙️ Kullanılan Teknolojiler

| Teknoloji | Kullanım |
|-----------|----------|
| Flutter 3.x | Mobil uygulama geliştirme |
| Firebase Realtime Database | Motor kataloğu ve geri bildirim depolama |
| Dart | Hesaplama motoru ve iş mantığı |
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

| Senaryo | T_cont | T_peak | t_cycle | n_max | Sonuç |
|---------|--------|--------|---------|-------|-------|
| Konveyör | 20 Nm | 50 Nm | 10s | 2000 rpm | 3 öneri |
| Pompa | 35 Nm | 70 Nm | 8s | 1500 rpm | 2 öneri |
| Asansör (SF=1.5) | 15 Nm | 100 Nm | 12s | 1800 rpm | 1 öneri |
| Termal Risk (42°C) | 50 Nm | 150 Nm | 5s | 3000 rpm | Öneri yok |
| Redüktörlü (i=5) | 80 Nm | 200 Nm | 10s | 300 rpm | Termal eleme |

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
- [x] Kullanıcı geri bildirim sistemi
- [x] Gerçek cihaz testi (5 senaryo)
- [x] Unit testler
- [ ] ML modeli entegrasyonu
- [ ] APK release build

---

## 👩‍💻 Geliştirici

**Sıla Deniz Esen**  
Bilgisayar Mühendisliği Bitirme Projesi  
Haziran 2026
