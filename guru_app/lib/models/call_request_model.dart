class CallRequestModel {
  final String id;
  final String memberId;
  final String trainerId;
  final DateTime requestedAt;
  final DateTime scheduledFor;
  final String note;
  final String status; // 'pending', 'approved', 'declined', 'cancelled'
  final String? declineReason;

  CallRequestModel({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.requestedAt,
    required this.scheduledFor,
    required this.note,
    required this.status,
    this.declineReason,
  });

  factory CallRequestModel.fromJson(Map<String, dynamic> json) {
    return CallRequestModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      note: json['note'] as String,
      status: json['status'] as String,
      declineReason: json['declineReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'trainerId': trainerId,
      'requestedAt': requestedAt.toIso8601String(),
      'scheduledFor': scheduledFor.toIso8601String(),
      'note': note,
      'status': status,
      if (declineReason != null) 'declineReason': declineReason,
    };
  }

  CallRequestModel copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? requestedAt,
    DateTime? scheduledFor,
    String? note,
    String? status,
    String? declineReason,
  }) {
    return CallRequestModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      note: note ?? this.note,
      status: status ?? this.status,
      declineReason: declineReason ?? this.declineReason,
    );
  }
}
