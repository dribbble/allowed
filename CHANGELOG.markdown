# Changelog

## 0.3.0 — Unreleased

* Switch to only supporting Rails 4.

## 0.2.1 — September 19th, 2014

* Undo the change in 0.1.4; only trigger callbacks in `after_rollback` to avoid losing changes in the rollback which occurs afterward.

## 0.2.0 — September 11th, 2014

* Provide a symbol as the limit to call a method on the record being saved.

## 0.1.4 — September 11th, 2014

* Ensure failure callbacks trigger even if rollback is not triggered.

## 0.1.3 — September 2nd, 2014

* Support Rails 3 and 4.

## 0.1.2 — June 9th, 2014

* Only handle callbacks after a rollback.

## 0.1.1 — June 9th, 2014

* Clear failed throttles after handling.

## 0.1.0 — June 6th, 2014

* Initial release.
