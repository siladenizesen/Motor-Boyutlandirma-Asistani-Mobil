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
