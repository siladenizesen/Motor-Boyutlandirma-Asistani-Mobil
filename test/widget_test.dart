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
