# ilkersevim_async_utils

Dependency-free Dart guards for coalescing concurrent async work and rejecting
stale async completions.

License: [Apache-2.0](LICENSE). Issues:
[github.com/redjadet/ilkersevim_async_utils/issues](https://github.com/redjadet/ilkersevim_async_utils/issues).

## Installation

Pub.dev (when published):

```yaml
dependencies:
  ilkersevim_async_utils: ^0.1.0
```

Git (until Pub.dev upload):

```yaml
dependencies:
  ilkersevim_async_utils:
    git:
      url: https://github.com/redjadet/ilkersevim_async_utils.git
      ref: v0.1.0
```

## InFlightCoalescer

One instance shares a single in-flight `Future<void>`. Concurrent callers await
the same future. Success or failure clears the gate so the next call starts
fresh.

```dart
final InFlightCoalescer coalescer = InFlightCoalescer();
Future<void> refresh() => coalescer.run(() => _doRefresh());
```

## KeyedInFlightCoalescer

Same idea, one in-flight future per key. Different keys run concurrently.

```dart
final KeyedInFlightCoalescer<String> coalescer =
    KeyedInFlightCoalescer<String>();
Future<void> refreshQuery(String query) =>
    coalescer.run(query, () => _doRefreshAndCache(query));
```

## RequestIdGuard

Ignore stale async completions (request-id pattern).

```dart
final RequestIdGuard guard = RequestIdGuard();
Future<void> load() async {
  final int id = guard.next();
  final result = await repository.fetch();
  if (!guard.isCurrent(id)) return;
  // apply result
}
```

## API stability

Public type names and method signatures are a semantic-versioned contract.
Breaking changes require a major version bump.
