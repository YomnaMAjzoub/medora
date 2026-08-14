/// Google Meet-style link helper for online consultations.
///
/// The backend does not expose a meeting-link field or endpoint (see the
/// Postman collection), so the app derives a deterministic link from the
/// appointment id. Both the patient and the doctor side compute the same
/// code for the same appointment, so they always land in the same room.
/// If the backend ever adds a `meeting_link` / `meet_link` response field,
/// it is read first via [fromJson].
class MeetLink {
  MeetLink._();

  static const _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHJKMNPQRSTUVWXYZ';
  static const _digits = '23456789';

  /// Reads an explicit link from an API response when present.
  static String? fromJson(Map<String, dynamic> json) {
    final raw = json['meeting_link'] ?? json['meet_link'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }

  /// Deterministic 12-character code: xxxx-xxxx-xxxx
  static String codeFor({required int appointmentId, required int seed}) {
    final charset = _lower + _upper + _digits;
    var value = appointmentId * 2654435761 + seed;
    final buffer = StringBuffer();
    for (var i = 0; i < 12; i++) {
      value = (value * 1103515245 + 12345) & 0x7fffffff;
      buffer.write(charset[value % charset.length]);
    }
    final code = buffer.toString();
    return '${code.substring(0, 4)}-${code.substring(4, 8)}-'
        '${code.substring(8, 12)}';
  }

  /// Full join URL for an appointment.
  static String forAppointment({
    required int appointmentId,
    required int seed,
  }) {
    return 'https://meet.google.com/${codeFor(appointmentId: appointmentId, seed: seed)}';
  }
}
