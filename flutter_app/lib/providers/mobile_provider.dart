import 'package:flutter_riverpod/flutter_riverpod.dart';

const kDesktopBreakpoint = 600.0;

final mobileLayoutProvider = Provider<double>((ref) => 0);

final isMobileLayoutProvider = Provider<bool>((ref) {
  final width = ref.watch(mobileLayoutProvider);
  return width < kDesktopBreakpoint;
}, dependencies: [mobileLayoutProvider],);