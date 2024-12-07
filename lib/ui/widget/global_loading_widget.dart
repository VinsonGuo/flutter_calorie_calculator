import 'package:flutter/material.dart';
import 'package:flutter_calorie_calculator/provider/app_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class GlobalLoadingWidget extends StatelessWidget {
  final Widget child;

  const GlobalLoadingWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AppProvider value) => value.isLoading);

    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black54, // 半透明背景
                child: Center(
                  child: LoadingAnimationWidget.stretchedDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 60,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
