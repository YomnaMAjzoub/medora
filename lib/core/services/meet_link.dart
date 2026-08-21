/// Google Meet link helper for online consultations.
///
/// The backend generates and stores the real link on the appointment
/// (`meet_link` column) when the final payment completes an online
/// appointment (PaymentServices::completeFinalPayment), and it is returned
/// by the appointment endpoints. This helper only reads that field from an
/// API response — no link is ever derived or invented client-side.
class MeetLink {
  MeetLink._();

  /// Reads the backend meeting link from an API response when present.
  static String? fromJson(Map<String, dynamic> json) {
    final raw = json['meeting_link'] ?? json['meet_link'];
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null;
  }
}
