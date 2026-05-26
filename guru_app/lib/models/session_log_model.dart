class SessionLogModel {
  final String id;
  final String memberId;
  final String trainerId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final int? rating; // 1-5
  final String? trainerNotes;
  final String? memberNotes;

  SessionLogModel({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    this.rating,
    this.trainerNotes,
    this.memberNotes,
  });

  factory SessionLogModel.fromJson(Map<String, dynamic> json) {
    return SessionLogModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSec: json['durationSec'] as int,
      rating: json['rating'] as int?,
      trainerNotes: json['trainerNotes'] as String?,
      memberNotes: json['memberNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'trainerId': trainerId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSec': durationSec,
      if (rating != null) 'rating': rating,
      if (trainerNotes != null) 'trainerNotes': trainerNotes,
      if (memberNotes != null) 'memberNotes': memberNotes,
    };
  }

  SessionLogModel copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    int? rating,
    String? trainerNotes,
    String? memberNotes,
  }) {
    return SessionLogModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      rating: rating ?? this.rating,
      trainerNotes: trainerNotes ?? this.trainerNotes,
      memberNotes: memberNotes ?? this.memberNotes,
    );
  }
}
