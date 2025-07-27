#!/usr/bin/env sh

__fsg_path="${(%):-%N}"

__fsg_git_check () {
  git rev-parse HEAD > /dev/null 2>&1 && return
  echo 'fzf-simple-git error: not in a git repo' >&2
  return 1
}

__fsg_awk_log () {
  # Helper script to work with `ctlr+h` git and fzf util:
  # Can't use `{8}` here, because `fzf` uses that for formatting:
  echo 'match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { printf substr($0, RSTART, RLENGTH) }'
}

__fsg_pager_data () {
  echo "GIT_PAGER='"$(__fsg_pager)"' LESS+=' -+F'"
}

__fsg_pager () {
  if [ ! -z "$FSG_PAGER" ]; then
    echo "$FSG_PAGER"
  fi

  if command -v 'delta' >/dev/null 2>&1; then
    local theme="${FSG_BAT_THEME:-${BAT_THEME:-GitHub}}"
    echo "delta --syntax-theme='"$theme"' --paging=always"
  else
    echo 'less'
  fi
}

__fsg_help_text=$(cat <<'EOF'


fzf-simple-git usage
--------------------

Start by pressing `ctlr-g` in a <git repo>, then:

- `ctrl+l` to show the interactive `git log` screen
- - `ctrl+d` to open a `diff` view since that commit
- - `ctrl+s` to open that commit with `show`
- - `ctrl+b` to open in browser (`gh` is required)

- `ctrl+b` to show the interactive `git branch` screen
- - `ctrl+d` to open a `diff` view since that commit
- - `ctrl+b` to open in browser (`gh` is required)

- `ctrl+t` to show the interactive `git tag` screen
- - `ctrl+d` to open a `diff` view since that commit
- - `ctrl+b` to open in browser (`gh` is required)

- `ctrl+f` to show files that are tracked by `git ls-files`
- - `ctrl+o` to open a file in `$EDITOR`
- - `ctrl+b` to open in browser (`gh` is required)
- - `ctrl+d` to show deleted files
- - `ctrl+r` to reload files
- - `ctrl+j` to show `git blame` for this file
- - - `ctrl+s` to open that commit with `show`
- - - `ctrl+j` to show the `git blame` before the selected commit
- - - `ctrl+r` to reload `git blame` for this file
- - - `ctrl+b` to open in browser (`gh` is required)

Common controls
---------------

- `ctrl+h` to toggle preview window
- `ctrl+]` to see this help

Enjoy!
EOF
)

__fsg_print_help () {
  local cmd
  if command -v 'bat' >/dev/null 2>&1; then
    cmd="bat -l markdown --paging=never --style=plain --color=always"
  else
    cmd='cat'
  fi

  if [ ! -z "$FZF_PREVIEW_COLUMNS" ]; then
    cmd="fold -s -w "$FZF_PREVIEW_COLUMNS" | $cmd"
  fi

  echo "$__fsg_help_text" | eval "$cmd"
}

# API that we allow to override:

_FSG_HEADER='ctrl-h to toggle preview, ctrl-] to show help in preview'

_fsg_fzf () {
  fzf --no-separator \
    --multi \
    --min-height 30 \
    --layout reverse \
    --ansi \
    --no-sort \
    --preview-window 'right,55%' \
    --header "$_FSG_HEADER" \
    --bind 'ctrl-h:change-preview-window(hidden|)' \
    --bind "ctrl-]:preview:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh"; __fsg_print_help)" \
    "$@"
}

export _FSG_HEADER
