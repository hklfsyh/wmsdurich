// lib/shared/models/warehouse_model.dart
import 'package:flutter/material.dart';
import 'package:wms_durich/core/theme/app_colors.dart';

enum DurianCondition {
  bagus,
  busuk,
  hancur,
  hilang,
}

class DurianConditionData {
  final String label;
  final Color bgColor;
  final Color textColor;

  DurianConditionData(this.label, this.bgColor, this.textColor);

  static DurianConditionData fromCondition(DurianCondition condition) {
    switch (condition) {
      case DurianCondition.bagus:
        return DurianConditionData(
            'Bagus', AppColors.statusSuccessLight, AppColors.statusSuccessDark);
      case DurianCondition.busuk:
        return DurianConditionData(
            'Busuk', AppColors.statusWarningLight, AppColors.statusWarningDark);
      case DurianCondition.hancur:
        return DurianConditionData(
            'Hancur', AppColors.statusDangerLight, AppColors.statusDangerDark);
      case DurianCondition.hilang:
        return DurianConditionData(
            'Hilang', AppColors.statusDangerLight, AppColors.statusDangerDark);
      default:
        return DurianConditionData('Tidak Diketahui', AppColors.fieldBackground,
            AppColors.textPrimary);
    }
  }
}

class WarehouseModel {
  final String warehouseId;
  final String fruitId;
  final String name;
  final DurianCondition condition;
  final double weightKg;
  final DateTime entryDate;

  WarehouseModel({
    required this.warehouseId,
    required this.fruitId,
    required this.name,
    required this.condition,
    required this.weightKg,
    required this.entryDate,
  });

  // Data Dummy
  static List<WarehouseModel> dummyData = [
    WarehouseModel(
      warehouseId: 'WH0104',
      fruitId: 'BT0202',
      name: 'Durian Black Thorn',
      condition: DurianCondition.bagus,
      weightKg: 2.5,
      entryDate: DateTime(2025, 11, 5),
    ),
    WarehouseModel(
      warehouseId: 'WH0103',
      fruitId: 'MV0101',
      name: 'Durian Monthong',
      condition: DurianCondition.hancur,
      weightKg: 1.3,
      entryDate: DateTime(2025, 11, 5),
    ),
    WarehouseModel(
      warehouseId: 'WH0102',
      fruitId: 'MV0102',
      name: 'Durian Monthong',
      condition: DurianCondition.bagus,
      weightKg: 3.0,
      entryDate: DateTime(2025, 11, 5),
    ),
    WarehouseModel(
      warehouseId: 'WH0101',
      fruitId: 'BT0201',
      name: 'Durian Black Thorn',
      condition: DurianCondition.busuk,
      weightKg: 1.8,
      entryDate: DateTime(2025, 11, 5),
    ),
  ];
}
