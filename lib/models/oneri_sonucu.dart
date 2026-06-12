import 'motor_model.dart';

class OneriSonucu {
  final MotorModel motor;
  final double puan;
  final double torkMarjiYuzde;
  final double hizMarjiYuzde;
  final List<String> avantajlar;
  final List<String> uyarilar;

  OneriSonucu({
    required this.motor,
    required this.puan,
    required this.torkMarjiYuzde,
    required this.hizMarjiYuzde,
    required this.avantajlar,
    required this.uyarilar,
  });
}

class IhtiyacOzeti {
  final double motorTarafiSurekliTorkNm;
  final double motorTarafiTepeTorkNm;
  final double motorTarafiMaxHizRpm;
  final double rmsTorkNm;
  final double guvenlikliTorkNm;
  final double ortalamaGucKw;

  IhtiyacOzeti({
    required this.motorTarafiSurekliTorkNm,
    required this.motorTarafiTepeTorkNm,
    required this.motorTarafiMaxHizRpm,
    required this.rmsTorkNm,
    required this.guvenlikliTorkNm,
    required this.ortalamaGucKw,
  });
}

class HesaplamaRaporu {
  final IhtiyacOzeti ihtiyacOzeti;
  final List<OneriSonucu> oneriler;
  final List<ElenmeNedeni> elenenMotorlar;

  HesaplamaRaporu({
    required this.ihtiyacOzeti,
    required this.oneriler,
    required this.elenenMotorlar,
  });
}

class ElenmeNedeni {
  final MotorModel motor;
  final String neden;

  ElenmeNedeni({required this.motor, required this.neden});
}
