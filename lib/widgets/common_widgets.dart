import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Background wrapper to match the mock gradient.
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final bool withSafeArea;
  const GradientScaffold({
    super.key,
    required this.child,
    this.withSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppTheme.notifier,
      builder: (context, theme, _) {
        final body = Container(
          decoration: BoxDecoration(gradient: AppGradients.bg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: KeyedSubtree(
                key: ValueKey('${theme.primary.value}-${theme.secondary.value}'),
                child: child,
              ),
            ),
          ),
        );

        return Scaffold(body: withSafeArea ? SafeArea(child: body) : body);
      },
    );
  }
}

/// Rounded “phone panel” look.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.panel,
        borderRadius: BorderRadius.circular(UI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HappyShopperLogo extends StatelessWidget {
  const HappyShopperLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          size: 44,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          'HAPPYSHOPPER',
          style: UI.subtitle().copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData? icon;
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = foregroundColor ?? AppTheme.secondary;
    final baseBackground = backgroundColor ?? Colors.white.withOpacity(0.18);
    final iconBadgeColor = foregroundColor ?? AppTheme.secondary;
    final showIconBadge = icon != null &&
        backgroundColor != null &&
        baseBackground.computeLuminance() > 0.8;
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseBackground,
          foregroundColor: foregroundColor ?? AppTheme.secondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: borderColor == null ? null : BorderSide(color: borderColor!),
        ),
        onPressed: onTap,
        child: icon == null
            ? Text(label, style: UI.buttonText().copyWith(color: textColor))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showIconBadge
                      ? Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: iconBadgeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 14, color: Colors.white),
                        )
                      : Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(label, style: UI.buttonText().copyWith(color: textColor)),
                ],
              ),
      ),
    );
  }
}

class CenterCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  const CenterCircleButton({
    super.key,
    required this.onTap,
    this.icon = Icons.add,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white.withOpacity(0.2);
    final fgColor = foregroundColor ?? Colors.white;
    return SizedBox(
      width: 44,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: const CircleBorder(),
        ),
        onPressed: onTap,
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class SocialSignInButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  const SocialSignInButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.secondary,
          side: BorderSide(color: AppTheme.secondary.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class ListRowButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const ListRowButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class EditRow extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  const EditRow({super.key, required this.title, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'edit',
              style: TextStyle(
                color: AppTheme.secondary.withOpacity(0.9),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
