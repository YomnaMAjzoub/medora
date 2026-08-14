import 'package:flutter/material.dart';
import 'package:medora_git/core/theme/app_theme.dart';



class SearchField extends StatelessWidget {
 const SearchField({
    required this.hint,
    required this.prefix,
    required this.suffix,
    required this.width,
    required this.height,
    this.onTap,
    super.key,
  });
  final double width;
  final double height;
  final String hint;
  final Widget prefix;
  final Widget suffix;
 final void Function()? onTap;
  
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width:width,
      height: height,
      child: TextFormField(
        onTap:onTap ,
        decoration: InputDecoration(
          prefixIcon: prefix,
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colors.textHint,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: colors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: colors.border, width: 1),
          ),
        ),
      ),
    );
  }
}
