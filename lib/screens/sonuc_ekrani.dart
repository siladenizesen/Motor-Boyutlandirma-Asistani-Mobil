import 'package:flutter/material.dart';
import '../models/oneri_sonucu.dart';
import '../models/motor_model.dart';
import '../services/firebase_servis.dart';
import '../models/giris_parametreleri.dart';

class SonucEkrani extends StatefulWidget {
  final HesaplamaRaporu rapor;
  final GirisParametreleri girisParametreleri;

  const SonucEkrani({
    super.key,
    required this.rapor,
    required this.girisParametreleri,
  });

  @override
  State<SonucEkrani> createState() => _SonucEkraniState();
}

class _SonucEkraniState extends State<SonucEkrani> {
  bool _elenenlerGosteriliyor = false;
  double _memnuniyetPuani = 4;
  bool _isinmaSorunu = false;
  bool _performansSorunu = false;

  Widget _ihtiyacOzeti() {
    final o = widget.rapor.ihtiyacOzeti;
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.analytics, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text('Motor Tarafı İhtiyaç Özeti',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue.shade800)),
            ]),
            const Divider(),
            _ozetSatiri('Sürekli Tork (güvenlikli)',
                '${o.guvenlikliTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('RMS Tork', '${o.rmsTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('Tepe Tork (motor tarafı)',
                '${o.motorTarafiTepeTorkNm.toStringAsFixed(1)} Nm'),
            _ozetSatiri('Maksimum Hız (motor tarafı)',
                '${o.motorTarafiMaxHizRpm.toStringAsFixed(0)} rpm'),
            _ozetSatiri('Ortalama Güç', '${o.ortalamaGucKw.toStringAsFixed(2)} kW'),
          ],
        ),
      ),
    );
  }

  Widget _ozetSatiri(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(deger,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _motorKarti(OneriSonucu oneri, int sira) {
    final motor = oneri.motor;
    final Color puanRengi = oneri.puan >= 70
        ? Colors.green.shade700
        : oneri.puan >= 45
            ? Colors.orange.shade700
            : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor:
                    sira == 0 ? Colors.amber.shade100 : Colors.grey.shade100,
                child: Text('${sira + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: sira == 0
                            ? Colors.amber.shade800
                            : Colors.grey.shade600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(motor.modelAdi,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                        '${motor.uretici} · ${motor.motorSinifi} · ${motor.verimSinifi}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: puanRengi.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: puanRengi.withOpacity(0.4)),
                ),
                child: Text('${oneri.puan.toStringAsFixed(0)} puan',
                    style: TextStyle(
                        color: puanRengi,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_outlined, size: 12, color: Colors.purple.shade700),
                    const SizedBox(width: 3),
                    Text(
                      'ML: ${oneri.mlSkoru.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _bilgeChip(
                    '${motor.nominalTorkNm}/${motor.maxTorkNm} Nm',
                    'nom/maks tork'),
                _bilgeChip('${motor.maxHizRpm.toStringAsFixed(0)} rpm', 'maks hız'),
                _bilgeChip('${motor.nominalGucKw} kW', 'güç'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _marjChip('Tork marjı', oneri.torkMarjiYuzde),
                _marjChip('Hız marjı', oneri.hizMarjiYuzde),
              ],
            ),
            if (oneri.avantajlar.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...oneri.avantajlar.map((a) => _bilgiSatiri(a, true)),
            ],
            if (oneri.uyarilar.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...oneri.uyarilar.map((u) => _bilgiSatiri(u, false)),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _geriBildirimDialog(motor),
              icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
              label: const Text('Bu motoru seçtim',
                  style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgeChip(String deger, String etiket) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(deger,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(etiket,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _marjChip(String etiket, double yuzde) {
    final renk = yuzde >= 10 && yuzde <= 35
        ? Colors.green
        : yuzde < 5
            ? Colors.orange
            : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: renk.shade200),
      ),
      child: Text('+${yuzde.toStringAsFixed(0)}% $etiket',
          style: TextStyle(fontSize: 11, color: renk.shade700)),
    );
  }

  Widget _bilgiSatiri(String metin, bool avantaj) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(children: [
        Icon(
            avantaj
                ? Icons.check_circle_outline
                : Icons.warning_amber_rounded,
            size: 14,
            color: avantaj ? Colors.green.shade600 : Colors.orange.shade700),
        const SizedBox(width: 5),
        Expanded(
            child: Text(metin,
                style: TextStyle(
                    fontSize: 12,
                    color: avantaj
                        ? Colors.green.shade700
                        : Colors.orange.shade800))),
      ]),
    );
  }

  void _geriBildirimDialog(MotorModel motor) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Geri Bildirim — ${motor.modelAdi}',
              style: const TextStyle(fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Memnuniyet (1–5):', style: TextStyle(fontSize: 13)),
              Slider(
                value: _memnuniyetPuani,
                min: 1,
                max: 5,
                divisions: 4,
                label: _memnuniyetPuani.toStringAsFixed(0),
                onChanged: (v) =>
                    setDialogState(() => _memnuniyetPuani = v),
              ),
              SwitchListTile(
                title: const Text('Isınma sorunu',
                    style: TextStyle(fontSize: 13)),
                value: _isinmaSorunu,
                onChanged: (v) =>
                    setDialogState(() => _isinmaSorunu = v),
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Performans sorunu',
                    style: TextStyle(fontSize: 13)),
                value: _performansSorunu,
                onChanged: (v) =>
                    setDialogState(() => _performansSorunu = v),
                dense: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await FirebaseServis.geriBildirimKaydet(
                    secilenMotorId: motor.motorId,
                    memnuniyetPuani: _memnuniyetPuani,
                    isinmaSorunu: _isinmaSorunu,
                    performansSorunu: _performansSorunu,
                    girisParametreleri: {
                      'sureklii_tork_Nm': widget.girisParametreleri.surekliTorkNm,
                      'tepe_tork_Nm': widget.girisParametreleri.tepeTorkNm,
                      'cevrim_suresi_sn': widget.girisParametreleri.cevrimSuresiSn,
                      'max_hiz_rpm': widget.girisParametreleri.maxHizRpm,
                      'motor_sinifi': widget.girisParametreleri.motorSinifi,
                    },
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Geri bildirim kaydedildi!'),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Kayıt hatası: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oneriler = widget.rapor.oneriler;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Önerileri'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ihtiyacOzeti(),
            const SizedBox(height: 16),
            if (oneriler.isEmpty)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Uygun motor bulunamadı. Parametreleri gözden geçiriniz.',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                ),
              )
            else ...[
              Text('${oneriler.length} uygun motor bulundu',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...oneriler.asMap().entries.map((e) => _motorKarti(e.value, e.key)),
            ],
            if (widget.rapor.elenenMotorlar.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => setState(
                    () => _elenenlerGosteriliyor = !_elenenlerGosteriliyor),
                icon: Icon(
                    _elenenlerGosteriliyor
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18),
                label: Text(
                    'Elenen motorlar (${widget.rapor.elenenMotorlar.length})',
                    style: const TextStyle(fontSize: 13)),
              ),
              if (_elenenlerGosteriliyor)
                ...widget.rapor.elenenMotorlar.map(
                  (e) => Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined,
                          color: Colors.red.shade300, size: 20),
                      title: Text(e.motor.modelAdi,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(e.neden,
                          style: TextStyle(
                              fontSize: 12, color: Colors.red.shade700)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
