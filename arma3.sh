#!/usr/bin/env bash
set -euo pipefail

# -- Config -------------------------------------------------------------------
STEAM_APPS="${HOME}/Library/Application Support/Steam/steamapps"
ARMA3_APPID="107410"
ARMA3_DIR="${STEAM_APPS}/common/Arma 3"
WORKSHOP_DIR="${STEAM_APPS}/workshop/content/${ARMA3_APPID}"
ARMA3_BIN="${ARMA3_DIR}/ArmA3.app/Contents/MacOS/ArmA3"


# -- Helpers ------------------------------------------------------------------
die() { echo "ERROR: $*" >&2; exit 1; }

mod_name() {
    local name
    name=$(grep -m1 '^name' "${1}/meta.cpp" 2>/dev/null | sed 's/^[^"]*"\(.*\)".*/\1/') || true
    # Strip characters invalid in a directory name, replace spaces with underscores
    name=$(echo "${name:-$(basename "$1")}" | tr '/: ' '_')
    echo "$name"
}

# -- Checks -------------------------------------------------------------------
[[ -x "$ARMA3_BIN" ]] || die "Arma 3 binary not found: $ARMA3_BIN"
[[ -d "$WORKSHOP_DIR" ]] || die "Workshop content dir not found: $WORKSHOP_DIR"

# -- Collect mods & create symlinks -------------------------------------------
mod_dirs=()
while IFS= read -r -d '' dir; do
    mod_dirs+=("$dir")
done < <(find "$WORKSHOP_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ ${#mod_dirs[@]} -eq 0 ]]; then
    echo "No workshop mods found — launching vanilla Arma 3."
    cd "${ARMA3_DIR}"
    exec "$ARMA3_BIN" "$@"
fi

# -- Remove dead symlinks -----------------------------------------------------
while IFS= read -r -d '' link; do
    [[ -e "$link" ]] || { echo "Removing dead symlink: $(basename "$link")"; rm "$link"; }
done < <(find "$ARMA3_DIR" -maxdepth 1 -name '@*' -type l -print0)

# -- Create symlinks for mods ------------------------------------------------
mod_args=()
echo "Mods (${#mod_dirs[@]}):"
for dir in "${mod_dirs[@]}"; do
    name="@$(mod_name "$dir")"
    link="${ARMA3_DIR}/${name}"

    # Create/update symlink inside the Arma 3 directory
    if [[ -L "$link" && "$(readlink "$link")" == "$dir" ]]; then
        : # already correct
    else
        ln -sfn "$dir" "$link"
    fi

    echo "  $name  →  $(basename "$dir")"
    mod_args+=("$name")
done

# -- Launch Arma 3 -----------------------------------------------------------
echo ""
echo "Launching Arma 3..."
cd "${ARMA3_DIR}"
exec "$ARMA3_BIN" "-mod=$(IFS=';'; echo "${mod_args[*]}")" "$@"
