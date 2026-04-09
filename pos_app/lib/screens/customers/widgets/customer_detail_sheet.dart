import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_model.dart';
import 'customer_detail_row.dart';

class CustomerDetailSheet extends StatelessWidget {
  final CustomerDetailsDto customer;
  const CustomerDetailSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customer.initials,
                style: GoogleFonts.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer.displayName,
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Customer since ${DateFormat('MMMM yyyy').format(customer.createdAt)}',
            style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Divider(),
          CustomerDetailRow('Phone', customer.phoneNumber ?? '—'),
          CustomerDetailRow('Email', customer.email ?? '—'),
          CustomerDetailRow(
            'Location',
            [
              customer.location,
              customer.city,
              customer.country,
            ].where((e) => e != null && e.isNotEmpty).join(', ').orDefault('—'),
          ),
          if (customer.notes != null) CustomerDetailRow('Notes', customer.notes!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

extension _StringExt on String {
  String orDefault(String fallback) => isEmpty ? fallback : this;
}
