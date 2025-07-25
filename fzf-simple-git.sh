#!/usr/bin/env sh

# === fzf-simple-git ===
# This is a copy-paste with modifications from
# https://github.com/junegunn/fzf-git.sh
# Which is cool, but very complex for my use-case,
# I only need commit log with interactive diffs.

# Private API, do not override:

__fsg_path=${(%):-%N}

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
    --preview-window 'right,55%' \
    --bind 'ctrl-h:change-preview-window(hidden|)' \
    "$@"
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
    --bind "ctrl-s:execute:($(__fsg_pager_data) git show \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-d:execute:($(__fsg_pager_data) git diff \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-b:execute:(gh browse \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --preview "echo {} | awk '$(__fsg_awk_log)' | xargs git show | $(__fsg_pager)" \
    "$@" | awk 'match($0, /[a-f0-9]{8}*/) { print substr($0, RSTART, RLENGTH) }'
}

__fsg_branch () {
  __fsg_git_check || return

  git branch \
    --sort=-committerdate \
    --sort=-HEAD \
    --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' |
  column -ts$'\t' |
  _fsg_fzf \
    --header 'ctrl-h to hide preview, ctrl-d for diff, ctrl-b to open in browser' \
    --bind "ctrl-d:execute:(git diff \$(echo {} | cut -c3- | cut -d' ' -f1))" \
    --bind "ctrl-b:execute:(gh browse --branch \$(echo {} | cut -c3- | cut -d' ' -f1))" \
    --preview "git log --oneline --graph --date=short --pretty='format:%C(auto)%cd %h%d %s' \$(echo {} | cut -c3- | cut -d' ' -f1) --" \
    "$@" | cut -c3- | cut -d' ' -f1
}

__fsg_files () {
  __fsg_git_check || return

  local fsg_file_preview

  if [[ -z "$FSG_FILE_PREVIEW" ]]; then
    fsg_file_preview='cat'

    if command -v 'bat' >/dev/null 2>&1; then
      fsg_file_preview='bat'
    fi

    # See source of this function here:
    # https://github.com/sobolevn/dotfiles/blob/master/config/zshenv
    if command -v '_fzf_complete_realpath' >/dev/null 2>&1; then
      fsg_file_preview='_fzf_complete_realpath'
    fi
  else
    fsg_file_preview="$FSG_FILE_PREVIEW"
  fi

  local query=''
  local root
  root="$(git rev-parse --show-toplevel)"
  if [[ "$root" != "$PWD" ]]; then
    query='!../ '
  fi

  git ls-files "$root" |
  _fsg_fzf \
    --query "$query" \
    --header 'ctrl-h for preview, ctlr-l/d for ls / deleted, ctrl-b to open in browser' \
    --bind 'ctrl-b:execute:(gh browse {})' \
    --bind 'ctrl-d:reload(git reflog --diff-filter D --pretty="format:" --name-only | sed "/^$/d")' \
    --bind "ctrl-l:reload(git ls-files "$root")" \
    --preview "$fsg_file_preview {}" \
    "$@"
}

# USAGE
# =====

__fsg_help () {
  cat <<'EOF'
fzf-simple-git usage
--------------------

Start by pressing `ctlr-g`, then:

- `ctrl+l` will show the interactive `git log` screen
- - from there `ctrl+d` will open a `diff` view since that commit
- - from there `ctrl+s` will open that commit with `show`
- - from there `ctrl+b` to open in browser (`gh` is required)

- `ctrl+b` will show the interactive `git branch` screen
- - from there `ctrl+d` will open a `diff` view since that commit
- - from there `ctrl+b` to open in browser (`gh` is required)

- `ctrl+f` will show the interactive `git ls-files` screen
- - from there `ctrl+d` to show only deleted files
- - from there `ctrl+b` to open in browser (`gh` is required)

- `ctrl+h` will show this help

Common controls
---------------

- `ctrl+a` to select multiple items
- `ctrl+h` to toggle preview window

EOF
}

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

    local m
    local o='h'

    # Init help:
    eval "__fsg_help_widget() { zle -M '$(__fsg_help)' }"
    eval "zle -N __fsg_help_widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '^g^${o[1]}' __fsg_help_widget"
      eval "bindkey -M $m '^g${o[1]}' __fsg_help_widget"
    done

    # Init commands:
    for o in "$@"; do
      eval "__fsg_${o}_widget() {
        local result=\$(__fsg_$o | __fsg_join);
        zle reset-prompt;
        LBUFFER+=\$result }"
      eval "zle -N __fsg_${o}_widget"
      for m in emacs vicmd viins; do
        eval "bindkey -M $m '^g^${o[1]}' __fsg_${o}_widget"
        eval "bindkey -M $m '^g${o[1]}' __fsg_${o}_widget"
      done
    done
  }
fi

__fsg_init log branch files
