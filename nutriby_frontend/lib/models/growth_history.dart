class GrowthHistory {
  final int id;
  final String recordDate;
  final double weight;
  final double height;
  final String nutritionalStatusHfa; 
  final double? zScoreHfa; 
  final double? zScoreWfa; 
  final double? zScoreWfh; 

  GrowthHistory({
    required this.id,
    required this.recordDate,
    required this.weight,
    required this.height,
    required this.nutritionalStatusHfa,
    this.zScoreHfa,
    this.zScoreWfa,
    this.zScoreWfh,
  });

  factory GrowthHistory.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value);
      return null;
    }

    return GrowthHistory(
      id: json['id'],
      recordDate: json['record_date'],
      weight: parseDouble(json['weight']) ?? 0.0,
      height: parseDouble(json['height']) ?? 0.0,
      nutritionalStatusHfa: json['nutritional_status_hfa'] ?? '-',

      zScoreHfa: parseDouble(json['z_score_hfa']),
      zScoreWfa: parseDouble(json['z_score_wfa']),
      zScoreWfh: parseDouble(json['z_score_wfh']),
    );
  }
}