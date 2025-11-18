import 'package:flutter/material.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/shared/models/warehouse_model.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final WarehouseModel item;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final description = [
      const TextSpan(text: 'Apakah anda yakin ingin menghapus data warehouse '),
      TextSpan(
        text: item.warehouseId,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.black),
      ),
      TextSpan(
          text: ' (',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.black)),
      TextSpan(
        text: item.name,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: AppColors.black),
      ),
      TextSpan(
          text: ')',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.black)),
      const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: AppColors.white,

      title: const Text(
        'Hapus Data Warehouse?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),

      // Konten/Deskripsi (Menggunakan RichText)
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),

      // Tombol Aksi
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            minimumSize: const Size(120, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: AppColors.textPlaceholder),
            ),
            elevation: 0,
          ),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.redSolid,
            foregroundColor: AppColors.white,
            minimumSize: const Size(120, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
