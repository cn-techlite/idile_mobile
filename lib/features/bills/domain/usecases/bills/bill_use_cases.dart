import 'package:idile_mobile_app/features/bills/domain/entities/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/payments/payment_record.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/domain/repositories/bills/bill_repository.dart';

final class BillUseCases {
  const BillUseCases(this._repository);

  final BillRepository _repository;

  Future<BillPage> bills(GetBillsRequest request) => _repository.bills(request);

  Future<Bill> bill(String billId) => _repository.bill(billId);

  Future<Bill> createBill(CreateBillRequest request) =>
      _repository.createBill(request);

  Future<Bill> updateBill(String billId, UpdateBillRequest request) =>
      _repository.updateBill(billId, request);

  Future<bool> deleteBill(String billId) => _repository.deleteBill(billId);

  Future<Bill> markPaid(String billId) => _repository.markPaid(billId);

  Future<List<PaymentRecord>> payments(GetBillPaymentsRequest request) =>
      _repository.payments(request);
}
