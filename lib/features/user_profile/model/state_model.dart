class StateModel {
  /// The unique ID from your API (e.g. "YOykazhq7aPokSM9K6Te")
  final String id;

  final String state;
  final int isActive;
  final String createdDate;
  final String lastUpdatedDate;
  final int createdById;
  final int lastUpdatedById;

  StateModel({
    required this.id,
    required this.state,
    required this.isActive,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.createdById,
    required this.lastUpdatedById,
  });

  /// Safely parse JSON, handling int-or-string for certain fields.
  factory StateModel.fromJson(Map<String, dynamic> json) {
    final isActiveRaw = json['is_active'];
    final cByIdRaw = json['createdById'];
    final lByIdRaw = json['lastUpdatedById'];

    return StateModel(
      /// Some APIs might not return 'id'. If so, fallback to empty string or handle accordingly
      id: json['id']?.toString() ?? '',

      state: json['state']?.toString() ?? '',
      isActive: isActiveRaw is int
          ? isActiveRaw
          : int.tryParse(isActiveRaw?.toString() ?? '') ?? 0,
      createdDate: json['created_date']?.toString() ?? '',
      lastUpdatedDate: json['last_updated_date']?.toString() ?? '',
      createdById: cByIdRaw is int
          ? cByIdRaw
          : int.tryParse(cByIdRaw?.toString() ?? '') ?? 0,
      lastUpdatedById: lByIdRaw is int
          ? lByIdRaw
          : int.tryParse(lByIdRaw?.toString() ?? '') ?? 0,
    );
  }

  /// When creating or updating, you might not need to send the "id"
  /// (depending on how your API works).
  Map<String, dynamic> toJson() {
    return {
      "state": state,
      "is_active": isActive,
      "created_date": createdDate,
      "last_updated_date": lastUpdatedDate,
      "createdById": createdById,
      "lastUpdatedById": lastUpdatedById,
    };
  }
}
