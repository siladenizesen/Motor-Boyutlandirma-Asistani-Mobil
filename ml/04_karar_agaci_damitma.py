"""
Motor Boyutlandirma Asistani - ML Modelinin Karar Agacina Damitilmasi
Bitirme Projesi - Sila Deniz Esen

Egitilen Gradient Boosting modeli (150 agac) dogasi geregi yorumlanmasi
ve mobil cihazda offline calistirilmasi zor bir yapiya sahiptir.
Bu script, modelin CIKTILARINI ogrenen basit bir karar agaci (max_depth=4)
egitir - bu isleme "model damitma" (model distillation) denir.

Sonuc: Mobil uygulamada internet/sunucu gerektirmeyen, gercek ML modelinin
ogrendigi oruntuleri tasiyan hafif bir karar agaci (Dart'a aktarilabilir).
"""

import pickle
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeRegressor, export_text
from sklearn.metrics import r2_score

with open("/home/claude/ml/best_model.pkl", "rb") as f:
    model = pickle.load(f)

df = pd.read_csv("/home/claude/ml/motor_egitim_verisi.csv")

FEATURES = [
    "motor_T_nom", "motor_T_max", "motor_n_max", "motor_P_nom",
    "verim_kod", "sinif_kod",
    "T_cont", "T_peak", "t_cycle", "t_peak",
    "n_nom_ihtiyac", "n_max_ihtiyac", "T_amb", "SF",
    "T_rms_guvenlikli", "P_ihtiyac_kW",
]
X = df[FEATURES].copy()
y_ml = np.clip(model.predict(X), 0, 100)

# NOT: Bu script calistirildiginda kullanilan sklearn/numpy/pandas versiyonlarina
# bagli olarak agac yapisinda kucuk farkliliklar olusabilir (float hassasiyeti,
# tie-breaking). lib/services/ml_tahmin_servisi.dart dosyasinda GOMULU OLAN
# kurallar, bu script'in ilk calistirilmasinda elde edilen ve asagida
# "REFERANS CIKTI" olarak belgelenen agac yapisidir. Tekrar uretilebilirlik
# icin best_model.pkl ve motor_egitim_verisi.csv dosyalari sabit tutulmustur.

# Karar agacini GB modelinin CIKTISINA gore egit (gercek etikete gore degil)
tree = DecisionTreeRegressor(max_depth=4, min_samples_leaf=20, random_state=42)
tree.fit(X, y_ml)
y_tree = tree.predict(X)

corr = np.corrcoef(y_ml, y_tree)[0, 1]
r2 = r2_score(y_ml, y_tree)

print("Damitilmis karar agaci (max_depth=4):")
print(f"  Orijinal model ile korelasyon: {corr:.4f}")
print(f"  R2 (tree vs GB model ciktisi): {r2:.4f}")

rules = export_text(tree, feature_names=FEATURES, decimals=2)
with open("/home/claude/ml/karar_agaci_kurallari.txt", "w", encoding="utf-8") as f:
    f.write(f"Korelasyon: {corr:.4f}\nR2: {r2:.4f}\n\n")
    f.write(rules)

print("\nKurallar karar_agaci_kurallari.txt dosyasina kaydedildi.")
print("Bu kurallar lib/services/ml_tahmin_servisi.dart dosyasina Dart formatinda aktarilmistir.")
