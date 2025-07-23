#!/usr/bin/env sh

# === fzf-simple-git ===
# This is a copy-paste with modifications from
# https://github.com/junegunn/fzf-git.sh
# Which is cool, but very complex for my use-case,
# I only need commit log with interactive diffs.

# Private API, do not override:

__fsg_git_check () {
  git rev-parse HEAD > /dev/null 2>&1 && return
  return 1
}

__fsg_awk_commit () {
  # Helper script to work with `ctlr+h` git and fzf util:
  # Can't use `{8}` here, because `fzf` uses that for formatting:
  echo 'match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { printf substr($0, RSTART, RLENGTH) }'
}

__fsg_pager_data () {
  echo "GIT_PAGER='"$(__fsg_pager)"' LESS='-+F'"
}

__fsg_pager () {
  if [[ ! -z "$FSG_PAGER" ]]; then
    echo "$FSG_PAGER"
  fi

  if command -v 'delta' >/dev/null 2>&1; then
    local theme="${FSG_BAT_THEME:-${BAT_THEME:-GitHub}}"
    echo "delta --syntax-theme="$theme" --paging=always"
  else
    echo 'less'
  fi
}

# API that we allow to override:

_fsg_fzf () {
  fzf --no-separator \
    --multi \
    --min-height 30 \
    --layout reverse \
    --ansi \
    --no-sort \
    --preview-window 'right,55%' "$@" \
    --bind 'ctrl-h:change-preview-window(hidden|)'
}

# Main:

__fsg_log () {
  __fsg_git_check || return

  # `--preview` and `--bind` commands have different structures,
  # because `--preview` does not respect `GIT_PAGER=` setting.
  git log \
    --date=short \
    --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" \
    --graph "$@" |
  _fsg_fzf \
    --header 'ctrl-h to hide preview, ctrl-s for show, ctrl-d for diff, ctrl-b to open in browser' \
    --bind "ctrl-s:execute:($(__fsg_pager_data) git show \"\$(echo {} | awk '$(__fsg_awk_commit)')\")" \
    --bind "ctrl-d:execute:($(__fsg_pager_data) git diff \"\$(echo {} | awk '$(__fsg_awk_commit)')\")" \
    --bind "ctrl-b:execute:(gh browse \"\$(echo {} | awk '$(__fsg_awk_commit)')\")" \
    --preview "echo {} | awk '$(__fsg_awk_commit)' | xargs git show | $(__fsg_pager)" \
    "$@" | awk 'match($0, /[a-f0-9]{8}*/) { print substr($0, RSTART, RLENGTH) }'
}

# USAGE
# =====
#
# Start by pressing `ctlr-g`, then:
# - `ctrl+l` will show the interactive `git log` screen
# - - from there `ctrl+d` will open a `diff` view since that commit
# - - from there `ctrl+s` will open that commit with `show`
# - - from there `ctrl+b` to open in browser (`gh` is required)
#
# Common controls
# ---------------
#
# - `ctrl+a` to select multiple items
# - `ctrl+h` to toggle preview window

if [[ -n "${BASH_VERSION:-}" ]]; then
  echo 'bash is not supported yet'
  exit 1
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  __fsg_join() {
    local item
    while read item; do
      echo -n "${(q)item} "
    done
  }

  __fsg_init() {
    setopt localoptions nonomatch
    local m o
    for o in "$@"; do
      eval "__fsg_$o_widget() {
        local result=\$(__fsg_$o | __fsg_join);
        zle reset-prompt;
        LBUFFER+=\$result
        }"
      eval "zle -N __fsg_$o_widget"
      for m in emacs vicmd viins; do
        eval "bindkey -M $m '^g^${o[1]}' __fsg_$o_widget"
        eval "bindkey -M $m '^g${o[1]}' __fsg_$o_widget"
      done
    done
  }
fi

__fsg_init log
