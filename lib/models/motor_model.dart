class MotorModel {
  final String motorId;
  final String modelAdi;
  final String uretici;
  final String motorSinifi;
  final String verimSinifi;
  final double nominalTorkNm;
  final double maxTorkNm;
  final double nominalHizRpm;
  final double maxHizRpm;
  final double nominalGucKw;
  final double nominalAkimA;
  final double nominalGerilimV;

  MotorModel({
    required this.motorId,
    required this.modelAdi,
    required this.uretici,
    required this.motorSinifi,
    required this.verimSinifi,
    required this.nominalTorkNm,
    required this.maxTorkNm,
    required this.nominalHizRpm,
    required this.maxHizRpm,
    required this.nominalGucKw,
    required this.nominalAkimA,
    required this.nominalGerilimV,
  });

  factory MotorModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MotorModel(
      motorId: id,
      modelAdi: map['model_adi'] ?? '',
      uretici: map['uretici'] ?? '',
      motorSinifi: map['motor_sinifi'] ?? 'asenkron',
      verimSinifi: map['verim_sinifi'] ?? 'IE3',
      nominalTorkNm: (map['nominal_tork_Nm'] ?? 0).toDouble(),
      maxTorkNm: (map['max_tork_Nm'] ?? 0).toDouble(),
      nominalHizRpm: (map['nominal_hiz_rpm'] ?? 0).toDouble(),
      maxHizRpm: (map['max_hiz_rpm'] ?? 0).toDouble(),
      nominalGucKw: (map['nominal_guc_kW'] ?? 0).toDouble(),
      nominalAkimA: (map['nominal_akim_A'] ?? 0).toDouble(),
      nominalGerilimV: (map['nominal_gerilim_V'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model_adi': modelAdi,
      'uretici': uretici,
      'motor_sinifi': motorSinifi,
      'verim_sinifi': verimSinifi,
      'nominal_tork_Nm': nominalTorkNm,
      'max_tork_Nm': maxTorkNm,
      'nominal_hiz_rpm': nominalHizRpm,
      'max_hiz_rpm': maxHizRpm,
      'nominal_guc_kW': nominalGucKw,
      'nominal_akim_A': nominalAkimA,
      'nominal_gerilim_V': nominalGerilimV,
    };
  }
}
