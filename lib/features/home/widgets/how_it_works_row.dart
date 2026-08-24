import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/how_it_works_step.dart';

/// Horizontal row of numbered steps explaining the GoLazy rental flow.
class HowItWorksRow extends StatelessWidget {
  const HowItWorksRow({super.key, required this.steps});

  final List<HowItWorksStep> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final step in steps) ...[
          Expanded(child: _HowItWorksStepTile(step: step)),
          if (step != steps.last)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _DashedConnector(),
            ),
        ],
      ],
    );
  }
}

class _HowItWorksStepTile extends StatelessWidget {
  const _HowItWorksStepTile({required this.step});

  final HowItWorksStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          '${step.stepNumber}. ${step.title}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DashedConnector extends StatelessWidget {
  const _DashedConnector();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 10,
      height: 1,
      child: DecoratedBox(decoration: BoxDecoration(color: AppColors.border)),
    );
  }
}
