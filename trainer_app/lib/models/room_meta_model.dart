class RoomMetaModel {
  final String id;
  final String callRequestId;
  final String hmsRoomId;
  final String hmsRoleMember;
  final String hmsRoleTrainer;

  RoomMetaModel({
    required this.id,
    required this.callRequestId,
    required this.hmsRoomId,
    required this.hmsRoleMember,
    required this.hmsRoleTrainer,
  });

  factory RoomMetaModel.fromJson(Map<String, dynamic> json) {
    return RoomMetaModel(
      id: json['id'] as String,
      callRequestId: json['callRequestId'] as String,
      hmsRoomId: json['hmsRoomId'] as String,
      hmsRoleMember: json['hmsRoleMember'] as String,
      hmsRoleTrainer: json['hmsRoleTrainer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callRequestId': callRequestId,
      'hmsRoomId': hmsRoomId,
      'hmsRoleMember': hmsRoleMember,
      'hmsRoleTrainer': hmsRoleTrainer,
    };
  }
}
