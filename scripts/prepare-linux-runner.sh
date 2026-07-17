#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if command -v fvm >/dev/null 2>&1; then
  flutter_cmd=(fvm flutter)
else
  flutter_cmd=(flutter)
fi

if [[ ! -d linux ]]; then
  cp pubspec.yaml "/tmp/motion-pubspec.$$.yaml"
  "${flutter_cmd[@]}" create \
    --platforms=linux \
    --project-name motion_shell \
    .
  mv "/tmp/motion-pubspec.$$.yaml" pubspec.yaml
  rm -f test/widget_test.dart
fi

runner=linux/runner/my_application.cc

python3 - "$runner" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

text = text.replace(
    "gboolean use_header_bar = TRUE;",
    "gboolean use_header_bar = FALSE;",
)

text = text.replace(
    "  gtk_widget_realize(GTK_WIDGET(window));\n",
    "",
)

original_order = (
    "  gtk_widget_realize(GTK_WIDGET(view));\n"
    "\n"
    "  fl_register_plugins(FL_PLUGIN_REGISTRY(view));"
)
required_order = (
    "  fl_register_plugins(FL_PLUGIN_REGISTRY(view));\n"
    "  gtk_widget_realize(GTK_WIDGET(view));"
)

if original_order in text:
    text = text.replace(original_order, required_order, 1)
elif required_order not in text:
    raise SystemExit(
        "Could not locate Flutter view registration order."
    )

text = text.replace(
    'gdk_rgba_parse(&background_color, "#000000");',
    'gdk_rgba_parse(&background_color, "#00000000");',
)

path.write_text(text)
PY

echo "Linux runner prepared for Motion layer shell."
