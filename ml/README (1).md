# ML Modeli — Motor Boyutlandırma Asistanı

Bu klasör, projenin makine öğrenmesi bileşenini içerir.

## Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `01_veri_uretimi.py` | 1260 kayıtlık sentetik eğitim verisi üretimi |
| `02_model_egitimi.py` | Linear Regression / Random Forest / Gradient Boosting karşılaştırması |
| `04_karar_agaci_damitma.py` | GB modelinin mobil uyumlu karar ağacına damıtılması |
| `motor_egitim_verisi.csv` | Üretilen eğitim verisi (1260 satır, 7 motor × 180 senaryo) |
| `best_model.pkl` | Eğitilmiş Gradient Boosting modeli (pickle) |
| `model_karsilastirma.csv` | 3 modelin RMSE/MAE/R² karşılaştırması |
| `ozellik_onem.csv` | Özellik önem sıralaması (feature importance) |
| `model_bilgisi.json` | Model meta verisi |
| `karar_agaci_referans.txt` | Dart koduna gömülen karar ağacının referans çıktısı |

## Çalıştırma Sırası

```bash
pip install pandas numpy scikit-learn
python 01_veri_uretimi.py
python 02_model_egitimi.py
python 04_karar_agaci_damitma.py
```

## Model Performansı (Test Seti, n=252)

| Model | RMSE | MAE | R² |
|-------|------|-----|-----|
| Linear Regression | 24.09 | 18.63 | 0.20 |
| Random Forest | 10.98 | 5.37 | 0.83 |
| **Gradient Boosting** | **10.90** | **5.84** | **0.84** |

## Mobil Entegrasyon

Gradient Boosting modeli (150 ağaç) doğrudan mobil cihazda çalıştırılamayacak
kadar büyük olduğu için, modelin çıktıları öğrenen basit bir karar ağacına
("damıtma" / distillation) dönüştürülmüştür. Bu ağaç `lib/services/ml_tahmin_servisi.dart`
dosyasında if-else yapısı olarak gömülmüştür ve internet/sunucu bağımlılığı
olmadan telefon üzerinde çalışır.

Damıtılmış ağaç ile orijinal model arasındaki uyum: **Korelasyon 0.88, R² 0.77**
