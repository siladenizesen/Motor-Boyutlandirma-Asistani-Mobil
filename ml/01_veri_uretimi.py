"""
Motor Boyutlandırma Asistanı - Sentetik Veri Seti Üretimi
Bitirme Projesi - Sıla Deniz Esen

Bu script, gerçek motor seçim mantığını taklit eden sentetik eğitim verisi üretir.
Her kayıt: bir motor + bir yük senaryosu kombinasyonu + "uygunluk skoru" etiketi.
Etiket, mevcut hesaplama motorundaki kurallarla (hard constraint + soft scoring)
tutarlı şekilde üretilir, böylece model gerçek mühendislik mantığını öğrenir.
"""

import numpy as np
import pandas as pd
import json

np.random.seed(42)

# ── Motor kataloğu (Firebase'deki ile aynı) ────────────────────────
MOTORS = [
    {"id": "motor_001", "model": "Siemens 1FK7-G2", "sinif": "servo", "verim": "IE4",
     "T_nom": 8.0, "T_max": 24.0, "n_nom": 3000, "n_max": 6000, "P_nom": 2.5},
    {"id": "motor_002", "model": "Siemens 1LE1001 5.5kW", "sinif": "asenkron", "verim": "IE3",
     "T_nom": 35.0, "T_max": 84.0, "n_nom": 1460, "n_max": 3000, "P_nom": 5.5},
    {"id": "motor_003", "model": "ABB M2BAX 7.5kW IE3", "sinif": "asenkron", "verim": "IE3",
     "T_nom": 49.0, "T_max": 118.0, "n_nom": 1460, "n_max": 3000, "P_nom": 7.5},
    {"id": "motor_004", "model": "ABB M2BAX 11kW IE4", "sinif": "asenkron", "verim": "IE4",
     "T_nom": 72.0, "T_max": 173.0, "n_nom": 1460, "n_max": 3000, "P_nom": 11.0},
    {"id": "motor_005", "model": "WEG W22 3kW IE3", "sinif": "asenkron", "verim": "IE3",
     "T_nom": 19.5, "T_max": 46.8, "n_nom": 1460, "n_max": 3000, "P_nom": 3.0},
    {"id": "motor_006", "model": "WEG W22 15kW IE4", "sinif": "asenkron", "verim": "IE4",
     "T_nom": 98.0, "T_max": 235.0, "n_nom": 1460, "n_max": 3000, "P_nom": 15.0},
    {"id": "motor_007", "model": "Siemens 1FK7 High Speed", "sinif": "servo", "verim": "IE4",
     "T_nom": 12.0, "T_max": 36.0, "n_nom": 4500, "n_max": 8000, "P_nom": 5.0},
]

VERIM_PUAN = {"IE4": 25, "IE3": 18, "IE2": 8}


def rms_tork(T_peak, T_cont, t_peak, t_cycle):
    t_off = max(t_cycle - t_peak, 0)
    return np.sqrt((T_peak**2 * t_peak + T_cont**2 * t_off) / t_cycle)


def hesapla_skor(motor, T_rms_guvenlikli, T_peak, n_max, T_amb, P_ihtiyac):
    """Mevcut Dart algoritmasıyla tutarlı puanlama (0-100)."""
    # Hard constraints
    if motor["T_nom"] < T_rms_guvenlikli:
        return 0.0
    if motor["T_max"] < T_peak:
        return 0.0
    if motor["n_max"] < n_max:
        return 0.0
    if T_amb > 40:
        return 0.0

    puan = 0.0
    tork_marji = (motor["T_nom"] - T_rms_guvenlikli) / T_rms_guvenlikli
    if 0.10 <= tork_marji <= 0.30:
        puan += 40
    elif tork_marji < 0.10:
        puan += 30
    elif tork_marji <= 0.60:
        puan += 20
    else:
        puan += 5

    hiz_marji = (motor["n_max"] - n_max) / n_max
    if 0.05 <= hiz_marji <= 0.30:
        puan += 20
    elif hiz_marji < 0.05:
        puan += 12
    elif hiz_marji <= 0.60:
        puan += 10
    else:
        puan += 3

    puan += VERIM_PUAN.get(motor["verim"], 5)

    guc_farki = abs(motor["P_nom"] - P_ihtiyac) / (P_ihtiyac + 0.001)
    if guc_farki <= 0.20:
        puan += 15
    elif guc_farki <= 0.50:
        puan += 8
    else:
        puan += 2

    return min(puan, 100)


# ── Senaryo üretimi ─────────────────────────────────────────────────
# Senaryoları motor kataloğunun kapsadığı aralıkta üretiyoruz ki
# pozitif (skor>0) örnekler de yeterli sayıda olsun.
records = []

n_scenarios = 150
for _ in range(n_scenarios):
    # Rastgele bir "hedef" motor seç ve onun civarında senaryo üret
    # (gerçek dünyada da ihtiyaçlar genelde kataloğa yakın olur)
    hedef = MOTORS[np.random.randint(len(MOTORS))]

    # Hedef motorun T_nom'unun %50-95'i kadar bir T_rms_guvenlikli hedefle
    SF = np.random.choice([1.25, 1.5])
    hedef_T_rms_guv = hedef["T_nom"] * np.random.uniform(0.5, 0.95)
    hedef_T_rms = hedef_T_rms_guv / SF

    t_cycle = np.random.uniform(4, 15)
    t_peak = np.random.uniform(1, min(t_cycle * 0.6, 6))
    t_off = t_cycle - t_peak

    # T_rms = sqrt((T_peak^2 * t_peak + T_cont^2 * t_off)/t_cycle) formülünden
    # T_cont ve T_peak'i geriye doğru türet
    oran = np.random.uniform(1.3, 2.5)  # T_peak / T_cont oranı
    # T_rms^2 * t_cycle = T_peak^2*t_peak + T_cont^2*t_off, T_peak = oran*T_cont
    denom = (oran**2) * t_peak + t_off
    T_cont = np.sqrt((hedef_T_rms**2 * t_cycle) / denom)
    T_peak = T_cont * oran

    n_nom = hedef["n_nom"] * np.random.uniform(0.4, 0.95)
    n_max = hedef["n_max"] * np.random.uniform(0.5, 0.95)
    T_amb = np.random.uniform(15, 38)  # ço\u011funlukla normal aral\u0131k

    T_rms = rms_tork(T_peak, T_cont, t_peak, t_cycle)
    T_rms_guv = T_rms * SF
    P_ihtiyac = (T_rms * n_nom * 2 * np.pi / 60) / 1000

    for motor in MOTORS:
        skor = hesapla_skor(motor, T_rms_guv, T_peak, n_max, T_amb, P_ihtiyac)
        records.append({
            "motor_id": motor["id"],
            "motor_sinifi": motor["sinif"],
            "verim_sinifi": motor["verim"],
            "motor_T_nom": motor["T_nom"],
            "motor_T_max": motor["T_max"],
            "motor_n_max": motor["n_max"],
            "motor_P_nom": motor["P_nom"],
            "T_cont": round(T_cont, 2),
            "T_peak": round(T_peak, 2),
            "t_cycle": round(t_cycle, 2),
            "t_peak": round(t_peak, 2),
            "n_nom_ihtiyac": round(n_nom, 0),
            "n_max_ihtiyac": round(n_max, 0),
            "T_amb": round(T_amb, 1),
            "SF": SF,
            "T_rms_guvenlikli": round(T_rms_guv, 2),
            "P_ihtiyac_kW": round(P_ihtiyac, 2),
            "uygunluk_skoru": round(skor, 1),
        })

# Ek olarak bazı tamamen rastgele (zorlayıcı/dengesiz) senaryolar da ekle
n_random = 30
for _ in range(n_random):
    T_cont = np.random.uniform(5, 100)
    T_peak = T_cont * np.random.uniform(1.2, 3.0)
    t_cycle = np.random.uniform(4, 15)
    t_peak = np.random.uniform(1, min(t_cycle * 0.6, 6))
    n_nom = np.random.choice([1460, 3000, 1500, 750])
    n_max = n_nom * np.random.uniform(1.0, 2.2)
    T_amb = np.random.uniform(15, 50)
    SF = np.random.choice([1.25, 1.5])

    T_rms = rms_tork(T_peak, T_cont, t_peak, t_cycle)
    T_rms_guv = T_rms * SF
    P_ihtiyac = (T_rms * n_nom * 2 * np.pi / 60) / 1000

    for motor in MOTORS:
        skor = hesapla_skor(motor, T_rms_guv, T_peak, n_max, T_amb, P_ihtiyac)
        records.append({
            "motor_id": motor["id"],
            "motor_sinifi": motor["sinif"],
            "verim_sinifi": motor["verim"],
            "motor_T_nom": motor["T_nom"],
            "motor_T_max": motor["T_max"],
            "motor_n_max": motor["n_max"],
            "motor_P_nom": motor["P_nom"],
            "T_cont": round(T_cont, 2),
            "T_peak": round(T_peak, 2),
            "t_cycle": round(t_cycle, 2),
            "t_peak": round(t_peak, 2),
            "n_nom_ihtiyac": round(n_nom, 0),
            "n_max_ihtiyac": round(n_max, 0),
            "T_amb": round(T_amb, 1),
            "SF": SF,
            "T_rms_guvenlikli": round(T_rms_guv, 2),
            "P_ihtiyac_kW": round(P_ihtiyac, 2),
            "uygunluk_skoru": round(skor, 1),
        })

df = pd.DataFrame(records)

# Verim sınıfını sayısala çevir (model girişi için)
verim_map = {"IE4": 4, "IE3": 3, "IE2": 2}
df["verim_kod"] = df["verim_sinifi"].map(verim_map)
sinif_map = {"servo": 1, "asenkron": 0}
df["sinif_kod"] = df["motor_sinifi"].map(sinif_map)

df.to_csv("/home/claude/ml/motor_egitim_verisi.csv", index=False)

print(f"Toplam kayıt: {len(df)}")
print(f"Senaryo sayısı: {n_scenarios}, Motor sayısı: {len(MOTORS)}")
print(f"\nSkor dağılımı:")
print(df["uygunluk_skoru"].describe())
print(f"\nSıfır olmayan skor oranı: {(df['uygunluk_skoru'] > 0).mean():.1%}")
print("\nÖrnek kayıtlar:")
print(df.head(3).to_string())
