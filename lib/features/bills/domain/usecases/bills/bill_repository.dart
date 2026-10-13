import 'package:idile_mobile_app/features/bills/data/dto/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/data/dto/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/data/model/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/data/model/payments/payment_record.dart';

abstract interface class BillRepository {
  Future<BillPage> bills(GetBillsRequest request);
  Future<Bill> bill(String billId);
  Future<Bill> createBill(CreateBillRequest request);
  Future<Bill> updateBill(String billId, UpdateBillRequest request);
  Future<bool> deleteBill(String billId);
  Future<Bill> markPaid(String billId);
  Future<List<PaymentRecord>> payments(GetBillPaymentsRequest request);
}
