#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  flutter_cmd=(fvm flutter)
  dart_cmd=(fvm dart)
else
  flutter_cmd=(flutter)
  dart_cmd=(dart)
fi

scripts/prepare-linux-runner.sh
"${flutter_cmd[@]}" pub get
"${dart_cmd[@]}" format --output=none --set-exit-if-changed lib bin test
"${flutter_cmd[@]}" analyze
"${flutter_cmd[@]}" test
"${flutter_cmd[@]}" build linux --release
mkdir -p build/service
"${dart_cmd[@]}" compile exe bin/motion_service.dart -o build/service/motion-service

echo 'Release bundle: build/linux/x64/release/bundle'
echo 'State service: build/service/motion-service'
