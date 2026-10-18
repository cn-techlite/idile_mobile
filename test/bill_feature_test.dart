import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idile_mobile_app/core/network/api_client.dart';
import 'package:idile_mobile_app/core/storage/session_store.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/create_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/get_bills_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/bills/update_bill_request.dart';
import 'package:idile_mobile_app/features/bills/domain/parameters/payments/get_bill_payments_request.dart';
import 'package:idile_mobile_app/features/bills/domain/entities/bills/bill.dart';
import 'package:idile_mobile_app/features/bills/data/service/bills/bill_remote_service.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/state_model/bill_state.dart';

void main() {
  test('validates and serializes bill requests and filters', () {
    expect(
      const CreateBillRequest(
        title: ' Ikeja Electric ',
        category: ' Utilities ',
        spaceId: 'space-id',
        amount: 25000,
        currencyId: 'currency-id',
        due: '2026-11-01',
        recurrence: 'Monthly',
      ).toJson(),
      {
        'title': 'Ikeja Electric',
        'category': 'Utilities',
        'spaceId': 'space-id',
        'amount': 25000,
        'currencyId': 'currency-id',
        'due': '2026-11-01',
        'recurrence': 'monthly',
      },
    );
    expect(const UpdateBillRequest(amount: 26000).toJson(), {'amount': 26000});
    expect(
      const GetBillsRequest(
        status: 'overdue',
        spaceId: 'space-id',
        category: 'Utilities',
        page: 2,
        limit: 50,
        sort: 'due:asc',
      ).toQueryParameters(),
      {
        'page': '2',
        'limit': '50',
        'status': 'overdue',
        'spaceId': 'space-id',
        'category': 'Utilities',
        'sort': 'due:asc',
      },
    );
    expect(() => const UpdateBillRequest().toJson(), throwsArgumentError);
    expect(
      () => const GetBillsRequest(status: 'unknown').toQueryParameters(),
      throwsArgumentError,
    );
  });

  test('uses the complete authenticated bills API contract', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final path = request.url.path;

      if (request.method == 'GET' && path == '/v1/bills') {
        expect(request.url.queryParameters, {
          'page': '1',
          'limit': '20',
          'status': 'upcoming',
          'spaceId': 'space-id',
          'sort': 'due:asc',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [_billJson()],
            'meta': {
              'pagination': {
                'page': 1,
                'limit': 20,
                'total': 42,
                'totalPages': 3,
                'hasNextPage': true,
                'hasPrevPage': false,
              },
            },
          }),
          200,
        );
      }
      if (request.method == 'GET' && path == '/v1/bills/bill-id') {
        return _response(_billJson());
      }
      if (request.method == 'POST' && path == '/v1/bills') {
        expect(jsonDecode(request.body)['recurrence'], 'monthly');
        return _response(_billJson(), statusCode: 201);
      }
      if (request.method == 'PATCH' && path == '/v1/bills/bill-id') {
        expect(jsonDecode(request.body), {'amount': 26000});
        return _response(_billJson(amount: 26000));
      }
      if (request.method == 'DELETE' && path == '/v1/bills/bill-id') {
        expect(request.body, isEmpty);
        return _response({'deleted': true});
      }
      if (request.method == 'PATCH' && path == '/v1/bills/bill-id/mark-paid') {
        expect(request.body, isEmpty);
        return _response(_billJson(status: 'paid'));
      }
      if (request.method == 'GET' && path == '/v1/bills/payments') {
        expect(request.url.queryParameters, {
          'spaceId': 'space-id',
          'billId': 'bill-id',
        });
        return _response([
          {
            'paidOn': '2026-10-01',
            'amount': 25000,
            'currencyId': 'currency-id',
            'billId': 'bill-id',
            'title': 'Ikeja Electric',
            'category': 'Utilities',
          },
        ]);
      }
      return http.Response('Not found', 404);
    });
    final service = BillRemoteService(
      ApiClient(
        client: client,
        store: SessionStore(storage: const FlutterSecureStorage()),
      ),
    );

    final page = await service.bills(
      const GetBillsRequest(status: 'upcoming', spaceId: 'space-id'),
    );
    final bill = await service.bill('bill-id');
    final created = await service.createBill(
      const CreateBillRequest(
        title: 'Ikeja Electric',
        category: 'Utilities',
        spaceId: 'space-id',
        amount: 25000,
        currencyId: 'currency-id',
        due: '2026-11-01',
        recurrence: 'monthly',
      ),
    );
    final updated = await service.updateBill(
      'bill-id',
      const UpdateBillRequest(amount: 26000),
    );
    final paid = await service.markPaid('bill-id');
    final payments = await service.payments(
      const GetBillPaymentsRequest(spaceId: 'space-id', billId: 'bill-id'),
    );
    final deleted = await service.deleteBill('bill-id');

    expect(page.bills.single.id, 'bill-id');
    expect(page.pagination.total, 42);
    expect(page.pagination.hasNextPage, isTrue);
    expect(bill.title, 'Ikeja Electric');
    expect(created.payments.single.amount, 25000);
    expect(updated.amount, 26000);
    expect(paid.status, 'paid');
    expect(payments.single.billId, 'bill-id');
    expect(deleted, isTrue);
  });

  test('appends paginated bills without duplicates', () {
    final first = BillPage(
      bills: [
        Bill.fromJson(_billJson()),
        Bill.fromJson(_billJson(id: 'two')),
      ],
      pagination: const BillPagination(
        page: 1,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: true,
        hasPrevPage: false,
      ),
    );
    final second = BillPage(
      bills: [
        Bill.fromJson(_billJson(id: 'two')),
        Bill.fromJson(_billJson(id: 'three')),
      ],
      pagination: const BillPagination(
        page: 2,
        limit: 2,
        total: 3,
        totalPages: 2,
        hasNextPage: false,
        hasPrevPage: true,
      ),
    );

    final state = BillState.fromPage(first).append(second);

    expect(state.bills.map((bill) => bill.id), ['bill-id', 'two', 'three']);
    expect(state.page, 2);
    expect(state.hasNextPage, isFalse);
  });
}

Map<String, dynamic> _billJson({
  String id = 'bill-id',
  double amount = 25000,
  String status = 'upcoming',
}) => {
  '_id': id,
  'userId': 'user-id',
  'title': 'Ikeja Electric',
  'category': 'Utilities',
  'spaceId': 'space-id',
  'amount': amount,
  'currencyId': 'currency-id',
  'due': '2026-11-01',
  'status': status,
  'recurrence': 'monthly',
  'payments': [
    {'paidOn': '2026-10-01', 'amount': 25000, 'currencyId': 'currency-id'},
  ],
  'createdAt': '2026-09-01T08:30:00.000Z',
  'updatedAt': '2026-10-01T08:30:00.000Z',
};

http.Response _response(Object data, {int statusCode = 200}) =>
    http.Response(jsonEncode({'success': true, 'data': data}), statusCode);
