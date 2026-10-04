import 'dart:async';

// Futures are returned to callers or passed to unawaited(); not discarded.
// ignore_for_file: discarded_futures

/// Single-flight gate: concurrent callers share one running [Future].
///
/// Use in repositories/services when multiple callers should await the same
/// in-flight work (e.g. refresh, pullRemote) instead of starting duplicate work.
///
/// Example:
/// ```dart
/// final InFlightCoalescer _coalescer = InFlightCoalescer();
/// Future<void> refresh() => _coalescer.run(() => _doRefresh());
/// ```
class InFlightCoalescer {
  Future<void>? _future;

  /// Runs [work] or returns the existing future if work is already in flight.
  /// When the future completes, the gate is cleared so the next call starts fresh.
  Future<void> run(Future<void> Function() work) {
    final Future<void>? inFlight = _future;
    if (inFlight != null) {
      return inFlight;
    }

    // Reserve the gate before [work] runs so reentrant [run] calls coalesce.
    final Completer<void> gate = Completer<void>();
    _future = gate.future;

    void finish() {
      if (identical(_future, gate.future)) {
        _future = null;
      }
    }

    try {
      Future<void>.sync(work).then<void>(
        (_) {
          if (!gate.isCompleted) {
            gate.complete();
          }
          finish();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!gate.isCompleted) {
            gate.completeError(error, stackTrace);
          }
          finish();
        },
      );
    } on Object catch (error, stackTrace) {
      if (!gate.isCompleted) {
        gate.completeError(error, stackTrace);
      }
      finish();
    }

    return gate.future;
  }
}

/// Keyed single-flight: one in-flight future per key.
///
/// Use when concurrent calls for the same key should share one run (e.g.
/// per-query refresh). Calls for different keys run concurrently.
///
/// Example:
/// ```dart
/// final KeyedInFlightCoalescer<String> _coalescer = KeyedInFlightCoalescer<String>();
/// Future<void> refreshQuery(String query) =>
///     _coalescer.run(query, () => _doRefreshAndCache(query));
/// ```
class KeyedInFlightCoalescer<K> {
  final Map<K, Future<void>> _byKey = <K, Future<void>>{};

  /// Runs [work] for [key], or returns the existing future if work for [key] is in flight.
  /// When the future completes, the key is cleared.
  Future<void> run(K key, Future<void> Function() work) {
    final Future<void>? inFlight = _byKey[key];
    if (inFlight != null) {
      return inFlight;
    }

    final Completer<void> gate = Completer<void>();
    _byKey[key] = gate.future;

    void finish() {
      if (identical(_byKey[key], gate.future)) {
        _byKey.remove(key);
      }
    }

    try {
      Future<void>.sync(work).then<void>(
        (_) {
          if (!gate.isCompleted) {
            gate.complete();
          }
          finish();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!gate.isCompleted) {
            gate.completeError(error, stackTrace);
          }
          finish();
        },
      );
    } on Object catch (error, stackTrace) {
      if (!gate.isCompleted) {
        gate.completeError(error, stackTrace);
      }
      finish();
    }

    return gate.future;
  }
}
