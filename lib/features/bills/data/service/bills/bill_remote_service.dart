import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/network/endpoints.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/payments/payment_record.dart';

class BillRemoteService {
  const BillRemoteService(this._api);

  final ApiClient _api;

  Future<BillPage> bills(GetBillsRequest request) {
    final uri = Uri(
      path: Endpoints.billsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.getEnvelope(
      uri.toString(),
      (value) => BillPage.fromEnvelope(Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<Bill> bill(String billId) => _api.get(
    Endpoints.billUrl(_validId(billId)),
    (value) => Bill.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<Bill> createBill(CreateBillRequest request) => _api.post(
    Endpoints.billsUrl,
    (value) => Bill.fromJson(Map<String, dynamic>.from(value as Map)),
    body: request.toJson(),
  );

  Future<Bill> updateBill(String billId, UpdateBillRequest request) =>
      _api.patch(
        Endpoints.billUrl(_validId(billId)),
        (value) => Bill.fromJson(Map<String, dynamic>.from(value as Map)),
        body: request.toJson(),
      );

  Future<bool> deleteBill(String billId) => _api.delete(
    Endpoints.billUrl(_validId(billId)),
    (value) => value is Map && value['deleted'] == true,
  );

  Future<Bill> markPaid(String billId) => _api.patch(
    Endpoints.markBillPaidUrl(_validId(billId)),
    (value) => Bill.fromJson(Map<String, dynamic>.from(value as Map)),
  );

  Future<List<PaymentRecord>> payments(GetBillPaymentsRequest request) {
    final uri = Uri(
      path: Endpoints.billPaymentsUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _api.get(
      uri.toString(),
      (value) => (value as List)
          .map(
            (item) =>
                PaymentRecord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }

  String _validId(String value) {
    final id = value.trim();
    if (id.isEmpty) {
      throw ArgumentError.value(value, 'billId', 'Bill id cannot be empty.');
    }
    return id;
  }
}
