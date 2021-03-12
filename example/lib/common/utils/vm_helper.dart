import 'dart:developer';

import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class VMHelper {
  factory VMHelper() => _vMHelper;
  VMHelper._();
  static final VMHelper _vMHelper = VMHelper._();
  Map<IsolateRef, MemoryUsage> memoryInfo = <IsolateRef, MemoryUsage>{};

  Map<IsolateRef, List<List<int>>> historyMemoryInfo =
      <IsolateRef, List<List<int>>>{};

  int _count = 0;
  int get count => _count;
  bool connected;
  VmService serviceClient;
  VM vm;
  Future<void> startConnect() async {
    final ServiceProtocolInfo info = await Service.getInfo();
    if (info == null || info.serverUri == null) {
      print('service  protocol url is null,start vm service fail');
      return;
    }
    final Uri uri = convertToWebSocketUrl(serviceProtocolUrl: info.serverUri);
    serviceClient = await vmServiceConnectUri(uri.toString(), log: StdoutLog());
    print('socket connected in service $info');
    connected = true;

    vm = await serviceClient.getVM();
    await updateMemoryUsage();
  }

  Future<void> updateMemoryUsage() async {
    if (vm != null && connected) {
      final List<IsolateRef> isolates = vm.isolates;
      for (int i = 0; i < isolates.length; i++) {
        final IsolateRef element = isolates[i];
        final MemoryUsage memoryUsage =
            await serviceClient.getMemoryUsage(element.id);
        memoryInfo[element] = memoryUsage;
        List<List<int>> lines = historyMemoryInfo[element];
        lines ??= List<List<int>>.filled(3, null);
        lines[0] ??= <int>[];
        lines[1] ??= <int>[];
        lines[2] ??= <int>[];
        lines[0].add(memoryUsage.heapUsage);
        lines[1].add(memoryUsage.heapCapacity);
        lines[2].add(memoryUsage.externalUsage);
        _count = lines[0].length;
        historyMemoryInfo[element] = lines;
      }
    }
  }
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print(message);

  @override
  void severe(String message) => print(message);
}

class ByteUtil {
  static String toByteString(int bytes) {
    if (bytes <= 1024) {
      return '${bytes}B';
    } else if (bytes <= 1024 * 1024) {
      return '${(bytes / (1024)).toStringAsFixed(2)}K';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}M';
    }
  }
}
