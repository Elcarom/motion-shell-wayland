#!/usr/bin/env python3
"""Offline structural validation for environments without Flutter/Dart."""
from __future__ import annotations

import configparser
import re
import sys
from pathlib import Path

import yaml
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    'pubspec.yaml',
    'lib/main.dart',
    'bin/motion_service.dart',
    'scripts/bootstrap-cachyos.sh',
    'scripts/build-release.sh',
    'scripts/install-user.sh',
    'systemd/motion-state.service',
    'config/hypr/motion.conf',
    'config/hypr/hypridle.conf',
    'config/hypr/hyprlock.conf',
    'config/hypr/hyprpaper.conf',
    'docs/DEMO.md',
    'docs/M3E_COMPONENT_AUDIT.md',
    'lib/widgets/motion_slider.dart',
    'lib/widgets/motion_buttons.dart',
    'lib/widgets/motion_icon_button.dart',
    'lib/integrations/audio/wpctl_parser.dart',
    'test/motion_slider_test.dart',
]


def fail(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    raise SystemExit(1)


def check_required() -> None:
    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            fail(f'missing required file: {relative}')


def strip_dart(source: str) -> str:
    """Replace comments and string contents while preserving delimiters/newlines."""
    out: list[str] = []
    i = 0
    block_depth = 0
    quote: str | None = None
    triple = False
    raw = False
    while i < len(source):
        if block_depth:
            if source.startswith('/*', i):
                block_depth += 1
                out.extend('  ')
                i += 2
            elif source.startswith('*/', i):
                block_depth -= 1
                out.extend('  ')
                i += 2
            else:
                out.append('\n' if source[i] == '\n' else ' ')
                i += 1
            continue
        if quote is not None:
            marker = quote * (3 if triple else 1)
            if source.startswith(marker, i):
                out.extend(' ' * len(marker))
                i += len(marker)
                quote = None
                triple = False
                raw = False
            elif not raw and source[i] == '\\':
                out.append(' ')
                i += 1
                if i < len(source):
                    out.append('\n' if source[i] == '\n' else ' ')
                    i += 1
            else:
                out.append('\n' if source[i] == '\n' else ' ')
                i += 1
            continue
        if source.startswith('//', i):
            end = source.find('\n', i)
            if end < 0:
                out.extend(' ' * (len(source) - i))
                break
            out.extend(' ' * (end - i))
            i = end
            continue
        if source.startswith('/*', i):
            block_depth = 1
            out.extend('  ')
            i += 2
            continue
        possible_raw = source[i] in 'rR' and i + 1 < len(source) and source[i + 1] in "'\""
        start = i + 1 if possible_raw else i
        if source[start] in "'\"":
            quote = source[start]
            triple = source.startswith(quote * 3, start)
            raw = possible_raw
            consumed = (start - i) + (3 if triple else 1)
            out.extend(' ' * consumed)
            i += consumed
            continue
        out.append(source[i])
        i += 1
    if block_depth:
        fail('unterminated Dart block comment')
    if quote is not None:
        fail('unterminated Dart string')
    return ''.join(out)


def check_dart_balancing() -> None:
    pairs = {')': '(', ']': '[', '}': '{'}
    for path in sorted([*ROOT.glob('lib/**/*.dart'), *ROOT.glob('bin/*.dart'), *ROOT.glob('test/*.dart')]):
        clean = strip_dart(path.read_text())
        stack: list[tuple[str, int]] = []
        for index, char in enumerate(clean):
            if char in '([{':
                stack.append((char, index))
            elif char in pairs:
                if not stack or stack[-1][0] != pairs[char]:
                    fail(f'unbalanced {char} in {path.relative_to(ROOT)} at byte {index}')
                stack.pop()
        if stack:
            fail(f'unclosed {stack[-1][0]} in {path.relative_to(ROOT)}')



def check_m3e_boundaries() -> None:
    forbidden_calls = re.compile(
        r'\b(?:Slider|SegmentedButton|FilledButton|ElevatedButton|OutlinedButton|TextButton|IconButton|CircularProgressIndicator)\s*\('
    )
    forbidden_import = re.compile(
        r"package:(?:m3e_buttons|icon_button_m3e|loading_indicator_m3e)/"
    )
    for path in sorted((ROOT / 'lib/surfaces').glob('*.dart')):
        source = strip_dart(path.read_text())
        match = forbidden_calls.search(source)
        if match:
            fail(
                f'direct pre-audit Material control in {path.relative_to(ROOT)}: '
                f'{match.group(0).strip()}'
            )
        raw = path.read_text()
        if forbidden_import.search(raw):
            fail(
                f'surface bypasses Motion M3E wrapper: {path.relative_to(ROOT)}'
            )


def check_expressive_slider_contract() -> None:
    source = (ROOT / 'lib/widgets/motion_slider.dart').read_text()
    required_tokens = (
        'GappedSliderTrackShape',
        'HandleThumbShape',
        'trackHeight: 16',
        'trackGap: 6',
        'semanticFormatterCallback',
    )
    for token in required_tokens:
        if token not in source:
            fail(f'MotionSlider lacks expressive contract token: {token}')
    if 'year2023' in source:
        fail('MotionSlider still relies on deprecated year2023 opt-in')

    pubspec = (ROOT / 'pubspec.yaml').read_text()
    if 'slider_m3e:' in pubspec:
        fail('stale slider_m3e dependency remains in pubspec')

    audit = (ROOT / 'docs/M3E_COMPONENT_AUDIT.md').read_text()
    if 'M3E desktop adaptation — provisional' not in audit:
        fail('slider audit does not disclose provisional M3E status')


def check_audio_endpoint_contract() -> None:
    service = (ROOT / 'bin/motion_service.dart').read_text()
    quick_settings = (ROOT / 'lib/surfaces/quick_settings.dart').read_text()
    parser = (ROOT / 'lib/integrations/audio/wpctl_parser.dart').read_text()
    required_service_methods = (
        'audio.output.volume.set',
        'audio.input.volume.set',
        'audio.output.device.set',
        'audio.input.device.set',
        'audio.output.mute.toggle',
        'audio.input.mute.toggle',
    )
    for method in required_service_methods:
        if method not in service:
            fail(f'audio IPC method missing: {method}')
    if service.count("case 'session.poweroff':") != 1:
        fail('session.poweroff switch label must appear exactly once')
    for token in ("title: 'Output'", "title: 'Input'", 'MotionSplitButton<String>', 'max: 1.5'):
        if token not in quick_settings:
            fail(f'control-center audio contract missing: {token}')
    for section in ('Sinks:', 'Sources:'):
        if section not in parser:
            fail(f'WirePlumber parser does not distinguish {section}')


def check_yaml() -> None:
    for relative in ['pubspec.yaml', 'analysis_options.yaml', '.github/workflows/ci.yml']:
        with (ROOT / relative).open() as stream:
            yaml.safe_load(stream)


def check_desktop_entries() -> None:
    for path in (ROOT / 'config/applications').glob('*.desktop'):
        parser = configparser.ConfigParser(interpolation=None, strict=True)
        parser.optionxform = str
        parser.read(path)
        if 'Desktop Entry' not in parser:
            fail(f'{path.name} lacks [Desktop Entry]')
        section = parser['Desktop Entry']
        for key in ('Type', 'Name', 'Exec'):
            if not section.get(key):
                fail(f'{path.name} lacks {key}')


def check_images() -> None:
    expected = {
        'assets/previews/quick-settings.png': (1600, 1000),
        'assets/previews/launcher.png': (1600, 1000),
        'assets/previews/overview.png': (1600, 1000),
        'assets/wallpaper.png': (2560, 1440),
    }
    for relative, size in expected.items():
        with Image.open(ROOT / relative) as image:
            if image.size != size:
                fail(f'{relative} is {image.size}, expected {size}')
            if image.getbbox() is None:
                fail(f'{relative} is empty')


def main() -> None:
    check_required()
    check_yaml()
    check_dart_balancing()
    check_m3e_boundaries()
    check_expressive_slider_contract()
    check_audio_endpoint_contract()
    check_desktop_entries()
    check_images()
    print('Offline structural validation passed.')


if __name__ == '__main__':
    main()
