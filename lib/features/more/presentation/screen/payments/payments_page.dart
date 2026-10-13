import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/bills/presentation/state/providers/bill_provider.dart';
import 'package:idile_mobile_app/features/home/presentation/state/providers/hearth_providers.dart';
import 'package:idile_mobile_app/shared/widgets/hearth_widgets.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const AppText.raw('Payments'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: SpaceSelector()),
        ],
      ),
      body: ref
          .watch(billPaymentControllerProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorState(
              error: e,
              onRetry: () => ref.invalidate(billPaymentControllerProvider),
            ),
            data: (payments) => payments.isEmpty
                ? const EmptyState(
                    icon: Icons.payments_outlined,
                    title: 'No recorded payments',
                    message:
                        'Payments appear here when you mark bills as paid.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: payments.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.check)),
                        title: AppText.raw(
                          payment.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: AppText.raw(
                          '${payment.category} · ${shortDate(payment.paidOn)}',
                        ),
                        trailing: AppText.raw(
                          money(payment.amount, payment.currencyId, catalog),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      );
                    },
                  ),
          ),
    );
  }
}
