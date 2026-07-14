#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  flutter_cmd=(fvm flutter)
else
  flutter_cmd=(flutter)
fi

if [[ ! -d linux ]]; then
  cp pubspec.yaml /tmp/motion-pubspec.$$.yaml
  "${flutter_cmd[@]}" create --platforms=linux --project-name motion_shell .
  mv /tmp/motion-pubspec.$$.yaml pubspec.yaml
  rm -f test/widget_test.dart
fi

runner=linux/runner/my_application.cc
python3 - "$runner" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace('gboolean use_header_bar = TRUE;', 'gboolean use_header_bar = FALSE;')
marker = '  gtk_window_set_default_size(window, 1280, 720);'
realize = '  gtk_widget_realize(GTK_WIDGET(window));'
if realize not in s:
if marker not in s:
raise SystemExit('Could not locate GTK window size setup.')
s = s.replace(marker, marker + '\n' + realize, 1)
p.write_text(s)
PY

echo 'Linux runner prepared for gtk-layer-shell.'
