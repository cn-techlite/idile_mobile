import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/shared/providers/connectivity_state.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProviders).value;
    if (status != ConnectivityStatus.isDisconnected) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Material(
          color: AppColors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 16,
                  color: AppColors.white,
                ),
                addHorizontalSpacing(2),
                Flexible(
                  child: AppText(
                    isBody: true,
                    text: 'Offline — showing saved data',
                    textAlign: TextAlign.center,
                    fontSize: 12,
                    color: AppColors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
