import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class FooterMark extends StatelessWidget {
  const FooterMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: AppColors.outlineVariant),
        const SizedBox(width: 12),
        Text(
          'Established MMXXIV',
          style: GoogleFonts.notoSerif(
            fontStyle: FontStyle.italic,
            fontSize: 12,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 40, height: 1, color: AppColors.outlineVariant),
      ],
    );
  }
}
