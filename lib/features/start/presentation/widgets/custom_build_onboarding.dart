import 'package:flutter/material.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';


class BuildOnboardingPage extends StatelessWidget {
  const BuildOnboardingPage({
    super.key,
    required this.description,
    required this.image,
    required this.title
    });
  final String image;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Card(
           color: AppColors.neutral700,      
            elevation: 10,
            shadowColor: AppColors.neutral400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            child: Container(
              width:double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:AppColors.secondary400,
                    spreadRadius:2,
                    blurRadius:1,
                    offset: const Offset(0, 1), 
                  ),
                ],
              ),

              child: Image.asset(
                image,
                height: MediaQuery.of(context).size.height * 0.377,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height:30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
