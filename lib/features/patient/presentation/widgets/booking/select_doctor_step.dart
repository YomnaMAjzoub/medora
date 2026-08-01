import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/doctor_card.dart';
import 'package:medora_git/features/patient/presentation/widgets/booking/doctor_filter_sheet.dart';

/// Step 1 of the booking flow: pick a doctor.
///
/// The doctor list below is static placeholder data -- swap [_doctors] for
/// data coming from [BookingController] once the backend is wired up.
/// Picking a doctor calls [BookingController.selectDoctor], which is the
/// one piece of state that actually needs to survive into later steps.
class SelectDoctorStep extends StatefulWidget {
  const SelectDoctorStep({super.key});

  static const _doctors = <DoctorModel>[
    DoctorModel(
      id: '1',
      name: 'Dr. Robert Chen',
      specialty: 'Interventional Cardiology',
      experienceYears: 15,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDVNkS3_1sXGWngRdoVq1yirhnxgIP9iS_N2w50wbQXnuhNEIX454uIzxW4dcIRS2fxp94q9_9xHJjDhS5lP8RA5DnPx-ixAYZ5-0mPU0SM90qCVVcU26GKFllMsWHnc9xQcXaSgaJPkeyv5_lJ4fm2iHqvvcG4LpaapzpBcfXmr-20zacaKvH71MQ9xsO1pYd4clIIiMqYEnHqm0Y2f3j2nF1v0VeLhx-qIjnt4ifIYHEjtH8CI9gj',
      rating: 4.9,
      reviewsCount: 210,
      pricePerSession: 120,
      supportedVisitTypes: [VisitType.clinic, VisitType.online],
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Sarah Al-Farsi',
      specialty: 'Pediatric Cardiology Specialist',
      experienceYears: 12,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuADJoRcYkZB1J0OduYW_Ba0nUgW3vLY2YBH-R3sE0sgyJg3yIm93m4MWR-McMp2_0Y1V37kRaEfbIiCysh9JvVSkKUOPzX2OGchduxuQFXoeH3hLufL741F2LVhPW853yk7qwwbjWwvxtvNJXE5WTv9h0gewasTTvcUFACGWN6vkHxKhU-FXsNYw93mnaAb7BL_nvOTRk2wXfGi3b87iG7I4-4hnd_YfCaGhqSzX5hPC-b7nS3gEnZU',
      rating: 5.0,
      reviewsCount: 420,
      pricePerSession: 150,
      supportedVisitTypes: [VisitType.home, VisitType.clinic, VisitType.online],
      isTopRated: true,
      highlightNote: 'Highly recommended for post-op recovery',
    ),
    DoctorModel(
      id: '3',
      name: 'Dr. James Wilson',
      specialty: 'Cardiovascular Surgery',
      experienceYears: 8,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCpRjMAYV-zkoq4Plt0hNuJ6_IwEYW-t3Re-pk11SBRZtXvyfBn2AZNFCA-CnQuutNRcJFXGsxhbpmkfubpAoFTnw7cX7gdMjbPkIY5Nz-nV0uQlxWQR6L_qQYm6XJHD3plFc8qQgks2bgR38k4_1YY1URW0cqzj2jZGGVoeSsMYbxI5EMZ51_vpH2l7uBTD1FtFwtUL2gG7GUqAhh9V48oKiWzBiXu4fAEskeYCOIOOjG7g4n3EEbd',
      rating: 4.7,
      reviewsCount: 96,
      pricePerSession: 180,
      supportedVisitTypes: [VisitType.clinic],
    ),
    DoctorModel(
      id: '4',
      name: 'Dr. Elena Rodriguez',
      specialty: 'General Cardiology',
      experienceYears: 10,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA2-lS9cbsz-psqFzoZqTsc7stilKnT042QHpOpytiCLNaJ0Id5GslXQNmzMIOJrkIO41LAcYS0DCP76AKnzHOwgzoxq0THH_BnomF7qBZO0rdvMXkaDTpIj13DBSg3h5UYWHPZISv2_OVxQ4Ahp9nsAQDJiM0Z4I2AOLolJkBbqanh2TgFoKNu0bqr2-igEQQYF9Lu_N-vcoYVrqD3tD2ntKIHPq7VGkjQJ_QfRyUfM0nP6AGoR6nG',
      rating: 4.8,
      reviewsCount: 132,
      pricePerSession: 95,
      supportedVisitTypes: [VisitType.home, VisitType.clinic, VisitType.online],
    ),
  ];

  @override
  State<SelectDoctorStep> createState() => _SelectDoctorStepState();
}

class _SelectDoctorStepState extends State<SelectDoctorStep> {
  final BookingController controller = Get.find<BookingController>();

  DoctorFilters _filters = const DoctorFilters();

  List<DoctorModel> get _filteredDoctors {
    return SelectDoctorStep._doctors.where((doctor) {
      return doctor.pricePerSession <= _filters.maxPrice;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showDoctorFilterSheet(context, _filters);
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Doctors',
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctors.length} doctors found at the clinic',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _FilterButton(onTap: _openFilterSheet),
            ],
          ),
          const SizedBox(height: 20),
          if (doctors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text(
                  'No doctors match your filters',
                  style: GoogleFonts.roboto(color: AppColors.grey300),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onBook: () => controller.selectDoctor(doctor),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary900,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list_rounded,
              size: 18,
              color: AppColors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'Filter',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
