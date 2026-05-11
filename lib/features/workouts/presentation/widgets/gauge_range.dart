class GaugeRange {
  final String label;
  final String value;
  final bool isActive;

  const GaugeRange({
    required this.label,
    required this.value,
    this.isActive = false,
  });
}
