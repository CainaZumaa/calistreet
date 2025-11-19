enum ProgressStatus {
  inProgress,
  completed,
  skipped,
}

class Progress {
  final String id;
  final String userId;
  final String? workoutId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationSeconds;
  final ProgressStatus status;
  final String? notes;
  final String? shareUrl;

  Progress({
    required this.id,
    required this.userId,
    this.workoutId,
    required this.startDate,
    this.endDate,
    this.durationSeconds,
    required this.status,
    this.notes,
    this.shareUrl,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      userId: json['user_id'],
      workoutId: json['workout_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      durationSeconds: json['duration_seconds'],
      status: _statusFromString(json['status']),
      notes: json['notes'],
      shareUrl: json['share_url'],
    );
  }

  static ProgressStatus _statusFromString(String? status) {
    switch (status) {
      case 'COMPLETED':
        return ProgressStatus.completed;
      case 'SKIPPED':
        return ProgressStatus.skipped;
      case 'IN_PROGRESS':
      default:
        return ProgressStatus.inProgress;
    }
  }

  static String _statusToString(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.completed:
        return 'COMPLETED';
      case ProgressStatus.skipped:
        return 'SKIPPED';
      case ProgressStatus.inProgress:
        return 'IN_PROGRESS';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'status': _statusToString(status),
      'notes': notes,
      'share_url': shareUrl,
    };
  }
}
