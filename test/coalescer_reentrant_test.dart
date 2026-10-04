import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:test/test.dart';

void main() {
  group('reentrant run', () {
    test('InFlightCoalescer coalesces nested run at start of work', () async {
      final InFlightCoalescer coalescer = InFlightCoalescer();
      int runs = 0;
      Future<void>? inner;

      await coalescer.run(() async {
        runs++;
        inner = coalescer.run(() async {
          runs++;
        });
      });

      await inner;
      expect(runs, 1);
    });

    test(
      'KeyedInFlightCoalescer coalesces nested run at start of work',
      () async {
        final KeyedInFlightCoalescer<String> coalescer =
            KeyedInFlightCoalescer<String>();
        int runs = 0;
        Future<void>? inner;

        await coalescer.run('k', () async {
          runs++;
          inner = coalescer.run('k', () async {
            runs++;
          });
        });

        await inner;
        expect(runs, 1);
      },
    );
  });
}
