
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'hide Trans;
import 'package:medora_git/common/widgets/elevated_button.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/start/presentation/widgets/custom_build_onboarding.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget { 
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPagesData = [
    {
      'image': 'assets/images/onboarding1.jpg',
      'title': 'welcome'.tr(),
      'description': 'onboarding_description1'.tr(),
    },
    {
      'image': 'assets/images/onboarding3.jpg',
      'title': 'onboarding_title2'.tr(),
      'description': 'onboarding_description2'.tr(),
    },
    {
      'image': 'assets/images/onboarding2.jpg',
      'title': 'onboarding_title3'.tr(),
      'description': 'onboarding_description3'.tr(),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                   Get.offNamed(AppRouter.role);
                  },
                  child: Text(
                    'skip'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary900,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingPagesData.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final pageData = onboardingPagesData[index];
                    return BuildOnboardingPage(
                      image: pageData['image']!,
                      title: pageData['title']!,
                      description: pageData['description']!,
                    );
                  },
                ),
              ),

              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingPagesData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary500,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                    spacing: 5.0,
                  ),
                ),
              ),
              SizedBox(height:40),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_currentPage != 0)
                  SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width * 0.43,
                    child: OutlinedButton(
                      onPressed:  () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                        
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(
                          color: AppColors.primary900,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'previous'.tr(),
                        style: TextStyle(
                          color: AppColors.primary900,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage != 0)
                  const SizedBox(width: 21),
                  Expanded(
                    child: CustomElevated(
                      text: _currentPage == onboardingPagesData.length - 1
                          ? 'start_now'.tr()
                          : 'next'.tr(),
                      height: 48,
                      width: MediaQuery.of(context).size.width * 0.43,
                      onPressed: () {
                        if (_currentPage < onboardingPagesData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          Get.offNamed(AppRouter.role);
                          //log('Finished onboarding! Navigate to main app.');
                        }
                      },
                      color: AppColors.primary900,
                      background: AppColors.primary900,
                      textColor: AppColors.yellow,
                    ),
                  ),
                ],
              ),
              SizedBox(height:20),
            ],
          ),
        ),
      ),
    );
  }
}
