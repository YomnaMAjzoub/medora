import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medora_git/common/widgets/search_field.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/patient/business_layer/controller/doctor_discovery_controller.dart';
import 'package:medora_git/features/patient/business_layer/controller/patient_account_controller.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';

import 'package:medora_git/features/patient/presentation/widgets/next_appointment_card.dart';
import 'package:medora_git/features/patient/presentation/widgets/patient_drawer.dart';
import 'package:medora_git/features/patient/presentation/widgets/section_title.dart';
import 'package:medora_git/features/patient/presentation/widgets/slider.dart';
import 'package:medora_git/features/patient/presentation/widgets/specialty_item.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discovery = Get.find<DoctorDiscoveryController>();
    final account = Get.find<PatientAccountController>();

    return Scaffold(
      drawer: PatientDrawer(),
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: context.appColors.primary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'patient_home_welecome'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.textPrimary,
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
              context.appColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ],
        actionsPadding: EdgeInsetsDirectional.only(end: 15),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  width: double.infinity,
                  height: 48,
                  hint: 'search_hint'.tr(),
                  prefix: Icon(Icons.search, color: context.appColors.primary),
                  suffix: Icon(
                    Icons.tune_rounded,
                    color: context.appColors.primary,
                  ),
                  onTap: () => Get.toNamed(AppRouter.doctorsList),
                ),
                const SizedBox(height: 24),

                SectionTitle(title: 'offers'.tr()),
                const SizedBox(height: 12),
                Obx(
                  () {
                    final offers = account.offerModels;
                    if (offers.isEmpty) return const SizedBox.shrink();
                    return SliderComponent(
                      offers: offers,
                      onOfferTap: (offer) {
                        if (offer.id == '3') {
                          Get.toNamed(AppRouter.conversations);
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                Obx(() {
                  final next = account.nextAppointment;
                  if (next == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: 'next_title'.tr(),
                        actionLabel: 'view_all'.tr(),
                        onActionTap: () => Get.toNamed(AppRouter.doctorsList),
                      ),
                      const SizedBox(height: 12),
                      NextAppointmentCard(
                        appointment: next,
                        onTap: () => Get.toNamed(AppRouter.doctorsList),
                        onActionTap: next.visitType == VisitType.online
                            ? () => _joinMeeting(next)
                            : null,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                SectionTitle(
                  title: 'specialists'.tr(),
                  actionLabel: 'see_all'.tr(),
                  onActionTap: () => Get.toNamed(AppRouter.doctorsList),
                ),
                const SizedBox(height: 14),
                Obx(
                  () {
                    if (discovery.isLoadingSpecializations.value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.appColors.primary,
                          ),
                        ),
                      );
                    }
                    if (discovery.specializationsError.value.isNotEmpty &&
                        discovery.specialties.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                discovery.specializationsError.value,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: context.appColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: discovery.fetchSpecializations,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.appColors.primaryContainer,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text('retry'.tr()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final specialties = discovery.specialties;
                    return SizedBox(
                      width: double.infinity,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: specialties.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final specialty = specialties[index];
                          return SpecialtyItem(
                            specialty: specialty,
                            onTap: () {
                              // The doctors-list screen applies the
                              // specialization filter on entry.
                              Get.toNamed(
                                AppRouter.doctorsList,
                                arguments: {
                                  'specialization': specialty.name,
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinMeeting(AppointmentModel appointment) {
    final link = appointment.meetLink;
    if (link == null || link.isEmpty) {
      Get.snackbar('warning'.tr(), 'no_meeting_link'.tr());
      return;
    }
    Get.defaultDialog(
      title: 'join_online_visit'.tr(),
      middleText: link,
      textCancel: 'cancel'.tr(),
      textConfirm: 'join'.tr(),
      confirmTextColor: AppColors.white,
      buttonColor: Get.context!.appColors.primaryContainer,
      onConfirm: () {
        Get.back();
        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      },
    );
  }
}
