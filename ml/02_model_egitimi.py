"""
Motor Boyutlandırma Asistanı - ML Model Eğitimi
Bitirme Projesi - Sıla Deniz Esen

Random Forest Regressor ile motor uygunluk skoru tahmini.
Girdi: yük parametreleri + motor özellikleri
Çıktı: 0-100 arası uygunluk skoru tahmini
"""

import pandas as pd
import numpy as np
import json
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import pickle

df = pd.read_csv("/home/claude/ml/motor_egitim_verisi.csv")

# ── Özellik seçimi ──────────────────────────────────────────────────
FEATURES = [
    "motor_T_nom", "motor_T_max", "motor_n_max", "motor_P_nom",
    "verim_kod", "sinif_kod",
    "T_cont", "T_peak", "t_cycle", "t_peak",
    "n_nom_ihtiyac", "n_max_ihtiyac", "T_amb", "SF",
    "T_rms_guvenlikli", "P_ihtiyac_kW",
]
TARGET = "uygunluk_skoru"

X = df[FEATURES]
y = df[TARGET]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print(f"Eğitim seti: {len(X_train)} kayıt")
print(f"Test seti: {len(X_test)} kayıt")

# ── Model karşılaştırması ───────────────────────────────────────────
models = {
    "Linear Regression": LinearRegression(),
    "Random Forest": RandomForestRegressor(n_estimators=150, max_depth=12, random_state=42),
    "Gradient Boosting": GradientBoostingRegressor(n_estimators=150, max_depth=4, learning_rate=0.1, random_state=42),
}

results = []
trained_models = {}

for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    y_pred = np.clip(y_pred, 0, 100)

    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)

    results.append({"Model": name, "RMSE": round(rmse, 2), "MAE": round(mae, 2), "R2": round(r2, 4)})
    trained_models[name] = model

    print(f"\n{name}:")
    print(f"  RMSE: {rmse:.2f}")
    print(f"  MAE:  {mae:.2f}")
    print(f"  R²:   {r2:.4f}")

results_df = pd.DataFrame(results)
results_df.to_csv("/home/claude/ml/model_karsilastirma.csv", index=False)
print("\n" + "="*50)
print(results_df.to_string(index=False))

# ── En iyi modeli seç (en yüksek R²) ────────────────────────────────
best_name = results_df.loc[results_df["R2"].idxmax(), "Model"]
best_model = trained_models[best_name]
print(f"\nEn iyi model: {best_name}")

# Feature importance (eğer varsa)
if hasattr(best_model, "feature_importances_"):
    importance_df = pd.DataFrame({
        "Özellik": FEATURES,
        "Önem": best_model.feature_importances_
    }).sort_values("Önem", ascending=False)
    importance_df.to_csv("/home/claude/ml/ozellik_onem.csv", index=False)
    print("\nÖzellik önem sıralaması:")
    print(importance_df.to_string(index=False))

# ── Modeli kaydet ────────────────────────────────────────────────────
with open("/home/claude/ml/best_model.pkl", "wb") as f:
    pickle.dump(best_model, f)

# Model bilgilerini JSON olarak kaydet (Flutter entegrasyonu için referans)
model_info = {
    "best_model": best_name,
    "features": FEATURES,
    "metrics": results_df.to_dict(orient="records"),
    "n_train": len(X_train),
    "n_test": len(X_test),
}
with open("/home/claude/ml/model_bilgisi.json", "w", encoding="utf-8") as f:
    json.dump(model_info, f, ensure_ascii=False, indent=2)

print("\nModel ve sonuçlar kaydedildi.")
