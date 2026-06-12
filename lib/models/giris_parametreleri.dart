class GirisParametreleri {
  final double surekliTorkNm;
  final double tepeTorkNm;
  final double cevrimSuresiSn;
  final double tepeSuresiSn;
  final bool yukTarafi;
  final double nominalHizRpm;
  final double maxHizRpm;
  final String beslemetipi;
  final double ortamSicakligiC;
  final String motorSinifi;
  final bool reduktorVar;
  final double reduktorOrani;
  final double mekanikVerim;
  final double guvenlikKatsayisi;

  GirisParametreleri({
    required this.surekliTorkNm,
    required this.tepeTorkNm,
    required this.cevrimSuresiSn,
    required this.tepeSuresiSn,
    required this.yukTarafi,
    required this.nominalHizRpm,
    required this.maxHizRpm,
    required this.beslemetipi,
    required this.ortamSicakligiC,
    required this.motorSinifi,
    required this.reduktorVar,
    required this.reduktorOrani,
    required this.mekanikVerim,
    required this.guvenlikKatsayisi,
  });
}
