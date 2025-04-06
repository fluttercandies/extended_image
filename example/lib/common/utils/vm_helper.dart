import 'dart:async';
import 'dart:developer';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class VMHelper with ChangeNotifier {
  factory VMHelper() => _vMHelper;

  VMHelper._() {
    assert(() {
      _startConnect().whenComplete(() {
        _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
          VMHelper()._updateMemoryUsage().whenComplete(() {
            notifyListeners();
          });
        });
      });
      return true;
    }());
  }

  static final VMHelper _vMHelper = VMHelper._();

  late bool connected;
  VmService? serviceClient;
  VM? vm;

  late MemoryUsage mainMemoryUsage;
  late Timer _timer;
  List<MyMemoryUsage> mainHistoryMemoryInfo = <MyMemoryUsage>[];

  IsolateRef? get main => vm!.isolates!
      .firstWhereOrNull((IsolateRef element) => element.name == 'main');

  int get count => _count;
  int _count = 0;

  Future<void> _startConnect() async {
    try {
      final ServiceProtocolInfo info = await Service.getInfo();
      if (info.serverUri == null) {
        print('Service protocol url is null, start vm service fail.');
        return;
      }
      final Uri uri = convertToWebSocketUrl(
        serviceProtocolUrl: info.serverUri!,
      );
      serviceClient = await vmServiceConnectUri(
        uri.toString(),
        log: StdoutLog(),
      );
      print('Socket connected in service $info');
      connected = true;
      vm = await serviceClient!.getVM();
      await _updateMemoryUsage();
    } catch (e) {
      print(
        'Socket connect failed due to $e. '
        "Make sure you're not using simulators.",
      );
    }
  }

  Future<void> _updateMemoryUsage() async {
    if (vm != null && connected) {
      final MemoryUsage memoryUsage = await serviceClient!.getMemoryUsage(
        main!.id!,
      );
      mainMemoryUsage = memoryUsage;
      final MyMemoryUsage latest = MyMemoryUsage.copyFromMemoryUsage(
        memoryUsage,
      );
      mainHistoryMemoryInfo.add(latest);
      mainHistoryMemoryInfo.removeWhere(
        (MyMemoryUsage element) => element.dataTime.isBefore(
          latest.dataTime.subtract(const Duration(minutes: 1)),
        ),
      );
    }
  }

  void clear() {
    _count = 0;
    mainHistoryMemoryInfo.clear();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void forceGC() {
    if (kDebugMode)
      serviceClient?.getAllocationProfile(main?.id ?? '', gc: true);
  }
}

class MyMemoryUsage {
  MyMemoryUsage({
    required int externalUsage,
    required int heapCapacity,
    required int heapUsage,
  })  : dataTime = DateTime.now(),
        externalUsage = externalUsage / 1024 / 1024,
        heapCapacity = heapCapacity / 1024 / 1024,
        heapUsage = heapUsage / 1024 / 1024;

  final DateTime dataTime;

  /// The amount of non-Dart memory that is retained by Dart objects. For
  /// example, memory associated with Dart objects through APIs such as
  /// Dart_NewFinalizableHandle, Dart_NewWeakPersistentHandle and
  /// Dart_NewExternalTypedData.  This usage is only as accurate as the values
  /// supplied to these APIs from the VM embedder or native extensions. This
  /// external memory applies GC pressure, but is separate from heapUsage and
  /// heapCapacity.
  final double externalUsage;

  /// The total capacity of the heap in bytes. This is the amount of memory used
  /// by the Dart heap from the perspective of the operating system.
  final double heapCapacity;

  /// The current heap memory usage in bytes. Heap usage is always less than or
  /// equal to the heap capacity.
  final double heapUsage;

  static MyMemoryUsage copyFromMemoryUsage(MemoryUsage memoryUsage) =>
      MyMemoryUsage(
        externalUsage: memoryUsage.externalUsage!,
        heapCapacity: memoryUsage.heapCapacity!,
        heapUsage: memoryUsage.heapUsage!,
      );

  double toDouble(double d) {
    return double.parse(d.toStringAsFixed(2));
  }
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print(message);

  @override
  void severe(String message) => print(message);
}

class ByteUtil {
  const ByteUtil._();

  static String toByteString(int bytes) {
    if (bytes <= 1024) {
      return '${bytes}B';
    } else if (bytes <= 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)}K';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}M';
    }
  }
}
