import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class HeaderScaffold extends StatelessWidget {
  const HeaderScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottomBar,
    this.showBackButton = true,
    this.onBack,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? bottomBar;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: bottomBar,
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 190 + topPadding,
            width: double.infinity,
            child: Image.asset(
              'assets/images/login_sky.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 66,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        if (showBackButton)
                          _BackButton(
                            onPressed: onBack ?? () => Navigator.maybePop(context),
                          ),
                        if (showBackButton) const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.headerTitle,
                          ),
                        ),
                        ...?actions,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}