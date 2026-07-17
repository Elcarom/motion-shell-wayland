#!/usr/bin/env fish

set -l role quick-settings
if test (count $argv) -ge 1
    set role $argv[1]
end

set -l binary build/linux/x64/debug/bundle/motion_shell
if not test -x $binary
    echo "Build the Linux debug bundle first: fvm flutter build linux --debug"
    exit 1
end

set -l environment \
    MOTION_LAYER_SHELL=1 \
    MOTION_SURFACE_ROLE=$role \
    GDK_BACKEND=wayland \
    XCURSOR_THEME=Adwaita \
    XCURSOR_SIZE=24

if test -d /tmp/motion-gtk-layer-0.10.0/usr/lib
    set -a environment \
        LD_LIBRARY_PATH=/tmp/motion-gtk-layer-0.10.0/usr/lib
end

env $environment $binary --surface=$role
