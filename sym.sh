#!/bin/bash

# Advanced symlink fixer

fix_symlink() {
    local path="$1"

    if [ -L "$path" ]; then
        real_target=$(readlink "$path")

        # If the real target is relative, resolve it
        if [[ "$real_target" != /* ]]; then
            real_target="$(dirname "$path")/$real_target"
        fi

        # Normalize path
        real_target=$(realpath -m "$real_target")

        if [ ! -e "$real_target" ]; then
            echo "Warning: Broken symlink: $path -> $real_target (Skipping)"
            return
        fi

        echo "Fixing symlink: $path -> $real_target"

        parent_dir=$(dirname "$path")
        link_name=$(basename "$path")

        # Remove symlink
        rm -f "$path"

        # Copy content
        if [ -d "$real_target" ]; then
            cp -a "$real_target" "$parent_dir/$link_name"
        else
            cp "$real_target" "$parent_dir/$link_name"
        fi

        echo "Fixed: $path now real."
    fi
}

# Main
start_path="${1:-.}"

echo "Scanning for symlinks inside: $start_path"

# Find all symlinks, sort by deepest first
mapfile -t symlinks < <(find "$start_path" -type l | awk '{ print length($0), $0 }' | sort -rn | cut -d' ' -f2-)

for symlink in "${symlinks[@]}"; do
    fix_symlink "$symlink"
done

echo "All symlinks fixed."
