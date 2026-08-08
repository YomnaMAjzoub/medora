import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/common/widgets/search_field.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_summary_model.dart';
import 'package:medora_git/features/patient/data/models/offer_model.dart';

import 'package:medora_git/features/patient/data/models/specialty_model.dart';

import 'package:medora_git/features/patient/presentation/widgets/next_appointment_card.dart';
import 'package:medora_git/features/patient/presentation/widgets/patient_drawer.dart';
import 'package:medora_git/features/patient/presentation/widgets/section_title.dart';
import 'package:medora_git/features/patient/presentation/widgets/slider.dart';
import 'package:medora_git/features/patient/presentation/widgets/specialty_item.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  static const _offers = <OfferModel>[
    OfferModel(
      id: '1',
      title: '20% off your first checkup',
      subtitle: 'Book any clinic visit this week',
    ),
    OfferModel(
      id: '2',
      title: 'Free home visit consultation',
      subtitle: 'Available for new patients',
    ),
    OfferModel(
      id: '3',
      title: 'Online consultations now live',
      subtitle: 'Talk to a doctor from home',
    ),
  ];

  static const _specialties = <SpecialtyModel>[
    SpecialtyModel(id: '1', name: 'Cardiology', icon: Icons.favorite_rounded),
    SpecialtyModel(
      id: '2',
      name: 'Dentistry',
      icon: Icons.medical_services_rounded,
    ),
    SpecialtyModel(
      id: '3',
      name: 'Dermatology',
      icon: Icons.face_retouching_natural_rounded,
    ),
    SpecialtyModel(id: '4', name: 'Pediatrics', icon: Icons.child_care_rounded),
    SpecialtyModel(
      id: '5',
      name: 'Orthopedics',
      icon: Icons.accessibility_new_rounded,
    ),
    SpecialtyModel(id: '6', name: 'Eyes', icon: Icons.visibility_rounded),
  ];

  static final _nextAppointment = AppointmentModel(
    id: '1',
    doctor: const DoctorSummaryModel(
      id: '1',
      name: 'Dr. Sarah Youssef',
      specialty: 'Cardiologist',
      imageUrl: null,
    ),
    date: DateTime.now().add(const Duration(days: 2)),
    time: '10:30 AM',
    visitType: VisitType.clinic,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PatientDrawer(),
      backgroundColor: AppColors.mainScreen,
      appBar: AppBar(
        backgroundColor: AppColors.mainScreen,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary700),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Welecome, Yomna',
          style: GoogleFonts.roboto(
            color: AppColors.grey600,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          SvgPicture.asset(
            'assets/icons/notify.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.primary700,
              BlendMode.srcIn,
            ),
          ),
        ],
        actionsPadding: EdgeInsetsDirectional.only(end: 15),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  width: double.infinity,
                  height: 48,
                  hint: 'Search doctors, specialties...',
                  prefix: const Icon(Icons.search, color: AppColors.primary700),
                  suffix: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary700,
                  ),
                  onTap: _noop,
                ),
                const SizedBox(height: 24),

                SectionTitle(title: 'offers'.tr()),
                const SizedBox(height: 12),
                SliderComponent(
                  offers: _offers,
                  onOfferTap: (offer) {
                    if (offer.id == '3') {
                      Get.toNamed(AppRouter.conversations);
                    }
                  },
                ),

                const SizedBox(height: 24),

                SectionTitle(
                  title: 'next_title'.tr(),
                  actionLabel: 'view_all'.tr(),
                  onActionTap: _noop,
                ),
                const SizedBox(height: 12),
                NextAppointmentCard(
                  appointment: _nextAppointment,
                  onTap: _noop,
                ),

                const SizedBox(height: 24),

                SectionTitle(
                  title: 'specialists'.tr(),
                  actionLabel: 'See all',
                  onActionTap: _noop,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 0.91,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _specialties.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SpecialtyItem(
                        specialty: _specialties[index],
                        onTap: _noop,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _noop() {}
}
