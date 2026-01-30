#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"
shift || true  # remove TARGET_DIR from $@

# Optional: list of patterns to include (default: all executables)
PATTERNS=("$@")
[[ ${#PATTERNS[@]} -eq 0 ]] && PATTERNS=("")

check_deps() {
    local deps=(tofi find)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo "Error: '$dep' is missing. It's like a pub with no beer." >&2
            exit 1
        fi
    done
}

launch() {
    local script_path="$1"
    local app_name="$2"
    (
        cd "$(dirname "$script_path")" || exit 1
        setsid "./$(basename "$script_path")" >/dev/null 2>&1 &
    )
    command -v notify-send >/dev/null && notify-send -a "Launcher" "Engaging $app_name"
}

main() {
    if [[ -z "$TARGET_DIR" ]]; then
        echo "Usage: $(basename "$0") /path/to/dir [patterns...]"
        exit 1
    fi

    [[ -d "$TARGET_DIR" ]] || { echo "Error: '$TARGET_DIR' is not a valid directory."; exit 1; }

    check_deps

    local -A apps
    for pattern in "${PATTERNS[@]}"; do
        while IFS= read -r -d '' file; do
            local parent script_base display_name
            parent="$(basename "$(dirname "$file")")"
            script_base="$(basename "$file")"

            # Name logic: if generic names, use parent folder
            [[ "$script_base" =~ ^(start|run|launch|play|main)(\..*)?$ ]] && \
                display_name="$parent" || display_name="$script_base"

            apps["$display_name"]="$file"
        done < <(find "$TARGET_DIR" -maxdepth 3 -not -path '*/.*' -type f -executable \
                 $( [[ -n "$pattern" ]] && echo "-name '$pattern'" ) -print0)
    done

    [[ ${#apps[@]} -eq 0 ]] && { echo "No executable scripts found in $TARGET_DIR."; exit 0; }

    local choice
    choice=$(printf "%s\n" "${!apps[@]}" | sort | tofi --prompt-text "   ")

    [[ -n "$choice" ]] && launch "${apps[$choice]}" "$choice"
}

main "$@"
