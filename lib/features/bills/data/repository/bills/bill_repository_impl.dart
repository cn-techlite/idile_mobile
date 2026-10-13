import 'package:idile_mobile_app/features/bills/data/dto/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/data/model/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/data/model/payments/payment_record.dart';
import 'package:idile_mobile_app/features/bills/data/service/bills/bill_remote_service.dart';
import 'package:idile_mobile_app/features/bills/domain/usecases/bills/bill_repository.dart';

class BillRepositoryImpl implements BillRepository {
  const BillRepositoryImpl(this._remoteService);

  final BillRemoteService _remoteService;

  @override
  Future<BillPage> bills(GetBillsRequest request) =>
      _remoteService.bills(request);

  @override
  Future<Bill> bill(String billId) => _remoteService.bill(billId);

  @override
  Future<Bill> createBill(CreateBillRequest request) =>
      _remoteService.createBill(request);

  @override
  Future<Bill> updateBill(String billId, UpdateBillRequest request) =>
      _remoteService.updateBill(billId, request);

  @override
  Future<bool> deleteBill(String billId) => _remoteService.deleteBill(billId);

  @override
  Future<Bill> markPaid(String billId) => _remoteService.markPaid(billId);

  @override
  Future<List<PaymentRecord>> payments(GetBillPaymentsRequest request) =>
      _remoteService.payments(request);
}
