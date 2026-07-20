import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

Future<void> main() async {
  final InFlightCoalescer coalescer = InFlightCoalescer();
  await coalescer.run(() async {});

  final RequestIdGuard guard = RequestIdGuard();
  final int requestId = guard.next();
  if (guard.isCurrent(requestId)) {
    print('latest request');
  }
}
