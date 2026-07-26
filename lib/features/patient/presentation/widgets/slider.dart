import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SliderComponent extends StatefulWidget {
 const  SliderComponent({super.key});

  @override
  State<SliderComponent> createState() => _SliderComponentState();
}

class _SliderComponentState extends State<SliderComponent> {

int activeIndex = 0;
final int sliderCount = 3;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 15,
    children:[
      CarouselSlider.builder(
        itemCount: sliderCount,
        itemBuilder: (context, index, realIndex) {
          return Stack(
            clipBehavior: Clip.none,
            children :[
              Container(
              width:393,
              padding: EdgeInsets.only(top:2,left:14,),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary500,
                      AppColors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
               
    ],
    );
          },

          options: CarouselOptions(
            clipBehavior: Clip.none,
            height:145,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction:1,
           // aspectRatio:2.0,
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
          count: sliderCount,
          effect:ColorTransitionEffect(
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
