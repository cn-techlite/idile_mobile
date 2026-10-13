import 'package:idile_mobile_app/app/router/route.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/helper_functions.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/features/auth/data/model/onbaording_data.dart';
import 'package:idile_mobile_app/features/auth/data/model/onboarding_model.dart';
import 'package:idile_mobile_app/features/auth/data/service/auth_local_storage_service.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_logo.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String routeName = "/Onboard";
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController pageController;
  int currentIndex = 0;
  final List<OnboardingModel> onboardingList = formattedOnboardingList;

  Future<void> nextPage() async {
    if (currentIndex == onboardingList.length - 1) {
      await _completeOnboarding();
      return;
    }
    await pageController.animateToPage(
      currentIndex + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeOnboarding() async {
    await AuthLocalStorageService().writeInt('onBoard', 0);
    if (!mounted) return;
    navPush(context, RootRoutes.getStarted);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = currentIndex == onboardingList.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 4),
              child: Row(
                children: [
                  const AppLogo(markSize: 38, nameSize: 29),
                  const Spacer(),
                  AppButton(
                    text: 'Skip',
                    onPressed: _completeOnboarding,
                    variant: AppButtonVariant.text,
                    compact: true,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingList.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (_, index) => _OnboardingPage(
                  item: onboardingList[index],
                  titleStyle: theme.textTheme.headlineMedium,
                  bodyStyle: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            SmoothPageIndicator(
              controller: pageController,
              count: onboardingList.length,
              effect: ExpandingDotsEffect(
                radius: 6,
                expansionFactor: 3,
                dotColor: theme.colorScheme.onSurface.withValues(alpha: .16),
                activeDotColor: theme.colorScheme.onSurface,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            addVerticalSpacing(2.75),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AppButton(
                isLoading: false,
                text: isLastPage ? 'Get Started' : 'Continue',
                onPressed: nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.item,
    required this.titleStyle,
    required this.bodyStyle,
  });

  final OnboardingModel item;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 590;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, compact ? 4 : 12, 24, 14),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: RadialGradient(
                      radius: .78,
                      colors: [
                        AppColors.signal.withValues(alpha: .20),
                        AppColors.signal.withValues(alpha: .07),
                        Colors.transparent,
                      ],
                      stops: const [0, .58, 1],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 4 : 10),
                    child: Image.asset(
                      item.image ?? '',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              addVerticalSpacing(compact ? 1.25 : 2.5),
              AppText(
                text: item.text ?? '',
                type: AppTextType.headlineMedium,
                textAlign: TextAlign.center,
                color: onSurface,
                fontSize: titleStyle?.fontSize,
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
              addVerticalSpacing(1.25),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: AppText(
                  text: item.pre ?? '',
                  type: AppTextType.bodyLarge,
                  textAlign: TextAlign.center,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  color: onSurface.withValues(alpha: .66),
                  fontSize: bodyStyle?.fontSize,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
