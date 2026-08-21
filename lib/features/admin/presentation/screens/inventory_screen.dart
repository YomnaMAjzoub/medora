import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/admin/data/models/item_model.dart';

/// Staff inventory list: fetched from getItems, with a use action per item
/// that consumes one unit (useItem) and refreshes the list.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  AdminController get controller => Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    if (!controller.isLoadingItems.value) {
      controller.fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'inventory'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoadingItems.value && controller.items.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.itemsError.value.isNotEmpty &&
              controller.items.isEmpty) {
            return _ErrorRetry(
              message: controller.itemsError.value,
              onRetry: controller.fetchItems,
            );
          }
          if (controller.items.isEmpty) {
            return Center(
              child: Text(
                'no_items'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return _ItemRow(
                item: item,
                isUsing: controller.usingItemIds.contains(item.id),
                onUse: () => _confirmUse(context, item),
              );
            },
          );
        }),
      ),
    );
  }

  void _confirmUse(BuildContext context, ItemModel item) {
    Get.dialog(
      AlertDialog(
        title: Text('use_item'.tr()),
        content: Text('use_item_confirm'.tr(args: [item.name])),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.useItem(item);
            },
            child: Text(
              'use_item'.tr(),
              style: TextStyle(color: context.appColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.isUsing,
    required this.onUse,
  });

  final ItemModel item;
  final bool isUsing;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_liquid_rounded,
                  size: 24,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (item.isLowStock
                          ? context.appColors.danger
                          : context.appColors.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.isLowStock ? 'low_stock'.tr() : 'in_stock'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.isLowStock
                        ? context.appColors.danger
                        : context.appColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'quantity'.tr()}: ${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: item.isOutOfStock
                        ? context.appColors.danger
                        : context.appColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${'min_quantity'.tr()}: ${item.minQuantity}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: item.isOutOfStock || isUsing ? null : onUse,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.primary,
                  disabledForegroundColor: context.appColors.textHint,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: isUsing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.remove_circle_outline_rounded, size: 18),
                label: Text('use_item'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: context.appColors.onPrimaryContainer,
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
}