import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.broken_image_outlined,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final value = url?.trim() ?? '';
    final uri = Uri.tryParse(value);
    final isValid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    final child = isValid
        ? Image.network(
            value,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : _ImagePlaceholder(
                    width: width,
                    height: height,
                    loading: true,
                    icon: placeholderIcon,
                  ),
            errorBuilder: (_, _, _) => _ImagePlaceholder(
              width: width,
              height: height,
              icon: placeholderIcon,
            ),
          )
        : _ImagePlaceholder(
            width: width,
            height: height,
            icon: placeholderIcon,
          );
    return borderRadius == null
        ? child
        : ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class AppCircleNetworkImage extends StatelessWidget {
  const AppCircleNetworkImage({
    required this.url,
    required this.radius,
    super.key,
    this.backgroundColor,
  });

  final String? url;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipOval(
      child: ColoredBox(
        color: backgroundColor ?? colors.surfaceContainerHighest,
        child: AppNetworkImage(
          url: url,
          width: radius * 2,
          height: radius * 2,
          placeholderIcon: Icons.person_outline,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    this.width,
    this.height,
    this.loading = false,
  });

  final double? width;
  final double? height;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: loading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Image.asset(
                  'assets/images/network_image_placeholder.png',
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(icon, color: colors.onSurfaceVariant),
                ),
        ),
      ),
    );
  }
}
