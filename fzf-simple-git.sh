#!/usr/bin/env sh

# === fzf-simple-git ===
# This is a copy-paste with modifications from
# https://github.com/junegunn/fzf-git.sh
# Which is cool, but very complex for my use-case,
# I only need simple stuff with interactivity.

# Private API, do not override:

__fsg_path="${(%):-%N}"
source "${__fsg_path:A:h}/fzf-simple-git-common.sh"

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
    --bind "ctrl-s:execute:($(__fsg_pager_data) git show \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-d:execute:($(__fsg_pager_data) git diff \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-b:execute:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh" && _fzf_git_cli \"\$(echo {} | awk '$(__fsg_awk_log)')\" &)" \
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
    --bind "ctrl-d:execute:(git diff \$(echo {} | cut -c3- | cut -d' ' -f1))" \
    --bind "ctrl-b:execute:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh" && _fzf_git_cli --branch \$(echo {} | cut -c3- | cut -d' ' -f1) &)" \
    --preview "git log --oneline --graph --date=short --pretty='format:%C(auto)%cd %h%d %s' \$(echo {} | cut -c3- | cut -d' ' -f1) --" \
    "$@" | cut -c3- | cut -d' ' -f1
}

__fsg_file () {
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
  if [[ "${root:u}" != "${PWD:u}" ]]; then
    query='!../ '
  fi

  git ls-files "$root" |
  _fsg_fzf \
    --query "$query" \
    --bind "ctrl-b:execute:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh" && _fzf_git_cli {} &)" \
    --bind 'ctrl-e:execute:($EDITOR {})' \
    --bind 'ctrl-d:reload(git reflog --diff-filter D --pretty="format:" --name-only | sed "/^$/d")' \
    --bind "ctrl-r:reload(git ls-files "$root")" \
    --bind "ctrl-j:become(source "${__fsg_path:A:h}/fzf-simple-git-blame.sh"; __fsg_blame {})" \
    --preview "$fsg_file_preview {}" \
    "$@"
}

__fsg_tag () {
  __fsg_git_check || return

  git tag --sort -version:refname |
  _fsg_fzf \
    --bind 'ctrl-d:execute:(git diff {})' \
    --bind "ctrl-b:execute:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh" && _fzf_git_cli {} &)" \
    --preview "git -c log.showSignature=false show {} | $(__fsg_pager)" \
    "$@"
}

# USAGE
# =====

__fsg_help () {
  __fsg_print_help
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

    # Init help:
    eval "__fsg_help_widget() { __fsg_help; zle reset-prompt }"
    eval "zle -N __fsg_help_widget"
    for m in emacs vicmd viins; do
      eval "bindkey -M $m '^g^]' __fsg_help_widget"
      eval "bindkey -M $m '^g]' __fsg_help_widget"
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

__fsg_init log branch file tag
