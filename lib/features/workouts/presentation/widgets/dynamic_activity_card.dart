import 'package:flutter/material.dart';

class DynamicActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String unit;
  final String status;
  final Color statusColor;
  final String activeLabel;
  final double progress; // 0.0 to 1.0

  const DynamicActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.status,
    required this.statusColor,
    required this.activeLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFA0A0A5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Color(0xFFA0A0A5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFD4FF45), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    activeLabel,
                    style: const TextStyle(
                      color: Color(0xFFD4FF45),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSegmentedProgressBar(),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sedentary", style: TextStyle(color: Color(0xFFA0A0A5), fontSize: 10)),
              Text("Moderate", style: TextStyle(color: Color(0xFFA0A0A5), fontSize: 10)),
              Text("Athlete", style: TextStyle(color: Color(0xFFA0A0A5), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = (totalWidth - 8) / 3;

        return Row(
          children: [
            _buildSegment(segmentWidth, progress > 0, progress <= 0.33 ? progress * 3 : 1.0),
            const SizedBox(width: 4),
            _buildSegment(segmentWidth, progress > 0.33, progress > 0.33 && progress <= 0.66 ? (progress - 0.33) * 3 : (progress > 0.66 ? 1.0 : 0.0)),
            const SizedBox(width: 4),
            _buildSegment(segmentWidth, progress > 0.66, progress > 0.66 ? (progress - 0.66) * 3 : 0.0),
          ],
        );
      },
    );
  }

  Widget _buildSegment(double width, bool isActive, double fill) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: UnalignedChild(
        alignment: Alignment.centerLeft,
        child: Container(
          width: width * fill,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFD4FF45),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              if (fill > 0)
                BoxShadow(
                  color: const Color(0xFFD4FF45).withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget to avoid full expansion inside Row
class UnalignedChild extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  const UnalignedChild({super.key, required this.child, required this.alignment});
  @override
  Widget build(BuildContext context) => Align(alignment: alignment, child: child);
}
