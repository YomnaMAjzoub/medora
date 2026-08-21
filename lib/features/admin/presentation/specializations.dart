/// Fixed specialization options for the staff Add/Edit Doctor forms.
///
/// The backend has no admin-facing specializations endpoint (the patient
/// one rejects admin tokens), so the forms use this curated list, rendered
/// exactly like the gender dropdown.
const List<String> kDoctorSpecializations = [
  'Allergy & Immunology',
  'Cardiology',
  'Dermatology',
  'Ear, Nose & Throat',
  'Endocrinology',
  'Gastroenterology',
  'General Surgery',
  'Internal Medicine',
  'Nephrology',
  'Neurology',
  'Obstetrics & Gynecology',
  'Ophthalmology',
  'Orthopedics',
  'Pediatrics',
  'Psychiatry',
  'Urology',
];