import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/payments/payment_record.dart';
import 'package:idile_mobile_app/features/bills/presentation/controller/bills/bill_controller.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/state_model/bill_state.dart';

final billControllerProvider = AsyncNotifierProvider<BillController, BillState>(
  BillController.new,
);

final billPaymentControllerProvider =
    AsyncNotifierProvider<BillPaymentController, List<PaymentRecord>>(
      BillPaymentController.new,
    );
