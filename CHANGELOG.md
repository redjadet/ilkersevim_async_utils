# Changelog

## 0.1.4

- Fix coalescers so a nested `run()` at the start of in-flight work shares the
  same gate instead of starting duplicate work (reentrant `Future.sync` window).

## 0.1.3

- Raise minimum SDK to Dart `>=3.13.0`.
- Pin CI to Dart 3.13.2 stable.

## 0.1.2

- Explain when coalescing and request guards prevent duplicate work and stale
  updates.
- Rewrite package metadata around those use cases.

## 0.1.1

- Docs: install section uses hosted pub.dev constraint only (package already published).
- Docs: document OIDC tag publish via GitHub Actions Environment `pub.dev`.

## 0.1.0

- Initial release of single-flight coalescers and request-ID staleness guard.
