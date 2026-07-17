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

if not command -q flock
    echo "Missing required command: flock from util-linux." >&2
    exit 1
end

set -l runtime_dir /run/user/(id -u)
if set -q XDG_RUNTIME_DIR
    if test -n "$XDG_RUNTIME_DIR"
        set runtime_dir $XDG_RUNTIME_DIR
    end
end

if not test -d "$runtime_dir"
    echo "Runtime directory does not exist: $runtime_dir" >&2
    exit 1
end

# Keep independent surfaces from blocking one another while preventing two
# instances of the same role from stacking layers and exclusive zones.
set -l lock_role (string replace -ar "[^A-Za-z0-9._-]" "_" -- $role)
set -l lock_file "$runtime_dir/motion-shell-$lock_role.lock"

flock -x -n -E 75 "$lock_file"     env $environment $binary --surface=$role

set -l launch_status $status
if test $launch_status -eq 75
    echo "Motion Shell surface $role is already running." >&2
end

exit $launch_status
