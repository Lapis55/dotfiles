#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
DEFAULT_PACKAGES="bash vim mintty codex"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: bash install.sh [--dry-run] [package...]

Packages:
  bash
  vim
  mintty
  codex
USAGE
}

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' is required. Install GNU Stow first."
}

package_targets() {
  case "$1" in
    bash) printf '%s\n' ".bashrc" ;;
    vim) printf '%s\n' ".vimrc" ".vim" ;;
    mintty) printf '%s\n' ".minttyrc" ;;
    codex) printf '%s\n' ".codex/AGENTS.md" ;;
    *) die "unknown package: $1" ;;
  esac
}

package_links() {
  case "$1" in
    bash) printf '%s\t%s\n' ".bashrc" ".bashrc" ;;
    vim)
      printf '%s\t%s\n' ".vimrc" ".vimrc"
      printf '%s\t%s\n' ".vim" ".vim"
      ;;
    mintty) printf '%s\t%s\n' ".minttyrc" ".minttyrc" ;;
    codex) printf '%s\t%s\n' "AGENTS.md" ".codex/AGENTS.md" ;;
    *) die "unknown package: $1" ;;
  esac
}

is_correct_link() {
  local target="$1"
  local expected="$2"

  [ -L "$target" ] || return 1
  [ -e "$target" ] || return 1
  [ "$(realpath "$target")" = "$(realpath "$expected")" ]
}

backup_conflicts() {
  local package="$1"
  local backup_root="$2"
  local source_rel target_rel target expected backup_path

  while IFS=$'\t' read -r source_rel target_rel; do
    target="$HOME/$target_rel"
    expected="$DOTFILES_DIR/$package/$source_rel"

    if [ -e "$target" ] || [ -L "$target" ]; then
      if is_correct_link "$target" "$expected"; then
        log "ok: $target already links to $expected"
      else
        backup_path="$backup_root/$target_rel"
        if [ "$DRY_RUN" -eq 1 ]; then
          log "would backup: $target -> $backup_path"
        else
          mkdir -p "$(dirname "$backup_path")"
          mv -- "$target" "$backup_path"
          log "backup: $target -> $backup_path"
        fi
      fi
    fi
  done < <(package_links "$package")
}

link_package() {
  local package="$1"
  local source_rel target_rel source target

  while IFS=$'\t' read -r source_rel target_rel; do
    source="$DOTFILES_DIR/$package/$source_rel"
    target="$HOME/$target_rel"

    [ -e "$source" ] || die "source path not found: $source"

    if is_correct_link "$target" "$source"; then
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      log "would link: $target -> $source"
    else
      mkdir -p "$(dirname "$target")"
      ln -s -- "$source" "$target"
      log "link: $target -> $source"
    fi
  done < <(package_links "$package")
}

main() {
  local packages=()
  local stow_packages=()
  local package timestamp backup_root stow_flags needs_stow

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run|-n)
        DRY_RUN=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        packages+=("$1")
        ;;
    esac
    shift
  done

  if [ "${#packages[@]}" -eq 0 ]; then
    # shellcheck disable=SC2206
    packages=($DEFAULT_PACKAGES)
  fi

  needs_stow=0
  for package in "${packages[@]}"; do
    if [ "$package" != "codex" ]; then
      needs_stow=1
    fi
  done

  [ -d "$DOTFILES_DIR" ] || die "$DOTFILES_DIR does not exist"
  if [ "$needs_stow" -eq 1 ]; then
    need_command stow
  fi
  need_command realpath

  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$DOTFILES_DIR/vim/.vim/autoload" \
             "$DOTFILES_DIR/vim/.vim/backup" \
             "$DOTFILES_DIR/vim/.vim/swap" \
             "$DOTFILES_DIR/vim/.vim/undo"
  fi

  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_root="$HOME/.dotfiles-backup/$timestamp"

  for package in "${packages[@]}"; do
    [ -d "$DOTFILES_DIR/$package" ] || die "package directory not found: $package"
    package_targets "$package" >/dev/null
    backup_conflicts "$package" "$backup_root"
    if [ "$package" = "codex" ]; then
      link_package "$package"
    else
      stow_packages+=("$package")
    fi
  done

  if [ "${#stow_packages[@]}" -eq 0 ]; then
    return
  fi

  stow_flags="-v"
  if [ "$DRY_RUN" -eq 1 ]; then
    stow_flags="-nv"
  fi

  log "stow packages: ${stow_packages[*]}"
  stow $stow_flags -d "$DOTFILES_DIR" -t "$HOME" "${stow_packages[@]}"
}

main "$@"
