import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/data/models/offer_model.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SliderComponent extends StatefulWidget {
  const SliderComponent({this.offers, super.key});

  final List<OfferModel>? offers;

  @override
  State<SliderComponent> createState() => _SliderComponentState();
}

class _SliderComponentState extends State<SliderComponent> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final offers = widget.offers;
    final itemCount = offers?.length ?? 3;

    return Column(
      spacing: 15,
      children: [
        CarouselSlider.builder(
          itemCount: itemCount,
          itemBuilder: (context, index, realIndex) {
            final offer = offers != null ? offers[index] : null;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 2, left: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary500, AppColors.white],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: offer == null
                  ? null
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              offer.title,
                              style: GoogleFonts.roboto(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              offer.subtitle,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
          options: CarouselOptions(
            clipBehavior: Clip.none,
            height: 145,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1,
            autoPlayAnimationDuration: const Duration(seconds: 1),
            autoPlayCurve: Curves.easeOut,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: itemCount,
          effect: ColorTransitionEffect(
            activeDotColor: AppColors.primary500,
            dotColor: Colors.grey.shade300,
            dotHeight: 10,
            dotWidth: 10,
            spacing: 5,
          ),
        ),
      ],
    );
  }
}
