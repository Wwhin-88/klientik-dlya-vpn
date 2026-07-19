import 'package:vpnchik/features/connection/notifier/connection_notifier.dart';
import 'package:vpnchik/features/stats/data/stats_data_providers.dart';
import 'package:vpnchik/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:vpnchik/utils/custom_loggers.dart';
import 'package:vpnchik/utils/riverpod_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_notifier.g.dart';

@riverpod
class StatsNotifier extends _$StatsNotifier with AppLogger {
  @override
  Stream<SystemInfo> build() {
    ref.disposeDelay(const Duration(seconds: 10));
    final serviceRunning = ref.watch(serviceRunningProvider);
    if (serviceRunning) {
      return ref
          .watch(statsRepositoryProvider)
          .watchStats()
          .map((event) => event.getOrElse((_) => SystemInfo.create()));
    } else {
      return Stream.value(SystemInfo.create());
    }
  }
}
