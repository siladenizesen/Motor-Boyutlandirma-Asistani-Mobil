import 'dart:math';
import '../models/giris_parametreleri.dart';
import '../models/motor_model.dart';
import '../models/oneri_sonucu.dart';
import 'ml_tahmin_servisi.dart';

class HesaplamaMotoru {
  static double motorTarafiTork(
    double yukTarafiTorkNm,
    double reduktorOrani,
    double mekanikVerim,
  ) {
    if (reduktorOrani <= 0 || mekanikVerim <= 0) return yukTarafiTorkNm;
    return yukTarafiTorkNm / (reduktorOrani * mekanikVerim);
  }

  static double motorTarafiHiz(double yukHizRpm, double reduktorOrani) {
    if (reduktorOrani <= 0) return yukHizRpm;
    return yukHizRpm * reduktorOrani;
  }

  static double rmsTork(
    double tepeTorkNm,
    double surekliTorkNm,
    double tepeSuresiSn,
    double cevrimSuresiSn,
  ) {
    if (cevrimSuresiSn <= 0) return tepeTorkNm;
    final tOff = cevrimSuresiSn - tepeSuresiSn;
    if (tOff < 0) return tepeTorkNm;
    final rmsSq =
        (pow(tepeTorkNm, 2) * tepeSuresiSn + pow(surekliTorkNm, 2) * tOff) /
        cevrimSuresiSn;
    return sqrt(rmsSq);
  }

  static double guvenlikliTork(double torkNm, double guvenlikKatsayisi) {
    return torkNm * guvenlikKatsayisi;
  }

  static double ortalamaGuc(double rmsTorkNm, double nominalHizRpm) {
    return (rmsTorkNm * nominalHizRpm * 2 * pi / 60) / 1000;
  }

  static IhtiyacOzeti ihtiyacHesapla(GirisParametreleri p) {
    final double motorSurekliTork = p.yukTarafi
        ? motorTarafiTork(p.surekliTorkNm, p.reduktorOrani, p.mekanikVerim)
        : p.surekliTorkNm;

    final double motorTepeTork = p.yukTarafi
        ? motorTarafiTork(p.tepeTorkNm, p.reduktorOrani, p.mekanikVerim)
        : p.tepeTorkNm;

    final double motorMaxHiz = p.yukTarafi
        ? motorTarafiHiz(p.maxHizRpm, p.reduktorOrani)
        : p.maxHizRpm;

    final double motorNomHiz = p.yukTarafi
        ? motorTarafiHiz(p.nominalHizRpm, p.reduktorOrani)
        : p.nominalHizRpm;

    final double rms = rmsTork(
      motorTepeTork,
      motorSurekliTork,
      p.tepeSuresiSn,
      p.cevrimSuresiSn,
    );

    final double guvenlikliT = guvenlikliTork(rms, p.guvenlikKatsayisi);
    final double ortGuc = ortalamaGuc(rms, motorNomHiz);

    return IhtiyacOzeti(
      motorTarafiSurekliTorkNm: motorSurekliTork,
      motorTarafiTepeTorkNm: motorTepeTork,
      motorTarafiMaxHizRpm: motorMaxHiz,
      rmsTorkNm: rms,
      guvenlikliTorkNm: guvenlikliT,
      ortalamaGucKw: ortGuc,
    );
  }

  static String? _kontrol(MotorModel motor, IhtiyacOzeti ihtiyac, double ortamC) {
    if (motor.nominalTorkNm < ihtiyac.guvenlikliTorkNm) {
      return 'Sürekli tork kapasitesi yetersiz '
          '(${motor.nominalTorkNm.toStringAsFixed(1)} Nm < '
          '${ihtiyac.guvenlikliTorkNm.toStringAsFixed(1)} Nm gerekli)';
    }
    if (motor.maxTorkNm < ihtiyac.motorTarafiTepeTorkNm) {
      return 'Tepe tork kapasitesi yetersiz '
          '(${motor.maxTorkNm.toStringAsFixed(1)} Nm < '
          '${ihtiyac.motorTarafiTepeTorkNm.toStringAsFixed(1)} Nm gerekli)';
    }
    if (motor.maxHizRpm < ihtiyac.motorTarafiMaxHizRpm) {
      return 'Maksimum hız yetersiz '
          '(${motor.maxHizRpm.toStringAsFixed(0)} rpm < '
          '${ihtiyac.motorTarafiMaxHizRpm.toStringAsFixed(0)} rpm gerekli)';
    }
    if (ortamC > 40) {
      return 'Ortam sıcaklığı ${ortamC.toStringAsFixed(0)}°C — derating gerektirir';
    }
    return null;
  }

  static double _puanla(MotorModel motor, IhtiyacOzeti ihtiyac) {
    double puan = 0;

    final torkMarji =
        (motor.nominalTorkNm - ihtiyac.guvenlikliTorkNm) /
        ihtiyac.guvenlikliTorkNm;
    if (torkMarji >= 0.10 && torkMarji <= 0.30) {
      puan += 40;
    } else if (torkMarji < 0.10) {
      puan += 30;
    } else if (torkMarji <= 0.60) {
      puan += 20;
    } else {
      puan += 5;
    }

    final hizMarji =
        (motor.maxHizRpm - ihtiyac.motorTarafiMaxHizRpm) /
        ihtiyac.motorTarafiMaxHizRpm;
    if (hizMarji >= 0.05 && hizMarji <= 0.30) {
      puan += 20;
    } else if (hizMarji < 0.05) {
      puan += 12;
    } else if (hizMarji <= 0.60) {
      puan += 10;
    } else {
      puan += 3;
    }

    switch (motor.verimSinifi) {
      case 'IE4':
        puan += 25;
        break;
      case 'IE3':
        puan += 18;
        break;
      case 'IE2':
        puan += 8;
        break;
      default:
        puan += 5;
    }

    final gucFarki = (motor.nominalGucKw - ihtiyac.ortalamaGucKw).abs() /
        (ihtiyac.ortalamaGucKw + 0.001);
    if (gucFarki <= 0.20) {
      puan += 15;
    } else if (gucFarki <= 0.50) {
      puan += 8;
    } else {
      puan += 2;
    }

    return puan.clamp(0, 100);
  }

  static HesaplamaRaporu hesaplaVeOner(
    GirisParametreleri giris,
    List<MotorModel> motorListesi,
  ) {
    final ihtiyac = ihtiyacHesapla(giris);
    final List<OneriSonucu> oneriler = [];
    final List<ElenmeNedeni> elenenler = [];

    for (final motor in motorListesi) {
      if (giris.motorSinifi != 'tumu' &&
          motor.motorSinifi != giris.motorSinifi) {
        elenenler.add(ElenmeNedeni(
          motor: motor,
          neden: 'Motor sınıfı uyumsuz '
              '(istenen: ${giris.motorSinifi}, katalog: ${motor.motorSinifi})',
        ));
        continue;
      }

      final neden = _kontrol(motor, ihtiyac, giris.ortamSicakligiC);
      if (neden != null) {
        elenenler.add(ElenmeNedeni(motor: motor, neden: neden));
        continue;
      }

      final puan = _puanla(motor, ihtiyac);
      final torkMarji = ((motor.nominalTorkNm - ihtiyac.guvenlikliTorkNm) /
              ihtiyac.guvenlikliTorkNm * 100).toDouble();
      final hizMarji = ((motor.maxHizRpm - ihtiyac.motorTarafiMaxHizRpm) /
              ihtiyac.motorTarafiMaxHizRpm * 100).toDouble();

      final avantajlar = <String>[];
      final uyarilar = <String>[];

      if (motor.verimSinifi == 'IE4') avantajlar.add('Yüksek verim sınıfı (IE4)');
      if (motor.verimSinifi == 'IE3') avantajlar.add('İyi verim sınıfı (IE3)');
      if (torkMarji >= 10 && torkMarji <= 30) {
        avantajlar.add('Tork marjı ideal (%${torkMarji.toStringAsFixed(0)})');
      }
      if (torkMarji > 60) uyarilar.add('Oversizing riski — tork %${torkMarji.toStringAsFixed(0)} fazla');
      if (giris.ortamSicakligiC > 35) uyarilar.add('Sıcak ortam — soğutmaya dikkat');

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
    }

    oneriler.sort((a, b) => b.puan.compareTo(a.puan));

    return HesaplamaRaporu(
      ihtiyacOzeti: ihtiyac,
      oneriler: oneriler,
      elenenMotorlar: elenenler,
    );
  }
}
