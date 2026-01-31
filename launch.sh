#!/usr/bin/env bash
#
# A launcher for scripts buried in subdirectories.
# Perfect for when your ~/bin is getting a bit crowded.

set -euo pipefail

TARGET_DIR="${1:-}"
shift || true

# Collect remaining arguments as patterns
PATTERNS=("$@")

check_deps() {
  local deps=(tofi find notify-send)
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

  # Move to the script's neighbourhood before launching
  (
    cd "$(dirname "$script_path")" || exit 1
    setsid "./$(basename "$script_path")" >/dev/null 2>&1 &
  )
  notify-send -a "Launcher" "Engaging $app_name"
}

main() {
  if [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: $(basename "$0") /path/to/dir [patterns...]"
    exit 1
  fi

  [[ -d "$TARGET_DIR" ]] || {
    echo "Error: '$TARGET_DIR' is not a valid directory. Mind the gap."
    exit 1
  }

  check_deps

  local -A apps=()

  # If no patterns, we search once for all; otherwise, loop through patterns.
  local search_list=("${PATTERNS[@]}")
  [[ ${#search_list[@]} -eq 0 ]] && search_list=("")

  for pattern in "${search_list[@]}"; do
    # Build the find command as an array to avoid quoting nightmares
    local find_cmd=(find "$TARGET_DIR" -maxdepth 3 -not -path '*/.*' -type f -executable)

    if [[ -n "$pattern" ]]; then
      find_cmd+=("-name" "$pattern")
    fi

    # Process substitution with a null terminator for safety
    while IFS= read -r -d '' file; do
      local parent script_base display_name
      parent="$(basename "$(dirname "$file")")"
      script_base="$(basename "$file")"

      # If the script has a generic name, use the folder name instead
      if [[ "$script_base" =~ ^(start|run|launch|play|main)(\..*)?$ ]]; then
        display_name="$parent"
      else
        display_name="$script_base"
      fi

      apps["$display_name"]="$file"
    done < <("${find_cmd[@]}" -print0)
  done

  if [[ ${#apps[@]} -eq 0 ]]; then
    echo "No executable scripts found. A bit of a barren wasteland, really."
    exit 0
  fi

  # Present the list to tofi
  local choice
  choice=$(printf "%s\n" "${!apps[@]}" | sort | tofi --prompt-text "   ")

  if [[ -n "$choice" ]]; then
    launch "${apps[$choice]}" "$choice"
  fi
}

main "$@"
