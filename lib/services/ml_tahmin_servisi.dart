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
library;

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
