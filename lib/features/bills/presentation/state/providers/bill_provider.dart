import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/bills/data/model/payments/payment_record.dart';
import 'package:idile_mobile_app/features/bills/data/repository/bills/bill_repository_impl.dart';
import 'package:idile_mobile_app/features/bills/data/service/bills/bill_remote_service.dart';
import 'package:idile_mobile_app/features/bills/domain/controller/bills/bill_controller.dart';
import 'package:idile_mobile_app/features/bills/domain/usecases/bills/bill_repository.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/state_model/bill_state.dart';

final billRemoteServiceProvider = Provider<BillRemoteService>(
  (ref) => BillRemoteService(ref.read(apiClientProvider)),
);

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepositoryImpl(ref.read(billRemoteServiceProvider)),
);

final billControllerProvider = AsyncNotifierProvider<BillController, BillState>(
  BillController.new,
);

final billPaymentControllerProvider =
    AsyncNotifierProvider<BillPaymentController, List<PaymentRecord>>(
      BillPaymentController.new,
    );
