#!/usr/bin/env sh

__fsg_path="${(%):-%N}"
source "${__fsg_path:A:h}/fzf-simple-git-common.sh"

# Subcommands that are not directly accessible.

__fsg_blame_cmd () {
  local ignore_file="${FSG_BLAME_IGNORE_FILE:-'.git-blame-ignore-revs'}"
  local blame_cmd='GIT_PAGER='' git blame -w -M3 --color-by-age --no-merges --date=short'
  if [ -f "$ignore_file" ]; then
    blame_cmd="$blame_cmd --ignore-revs-file="$ignore_file""
  fi
  if [ ! -z "$2" ]; then
    # Adjust blame to show only recent commits:
    blame_cmd="$blame_cmd $2"

    # Check that it is not an initial commit
    local initial_hash
    initial_hash="$(git rev-list --max-parents=0 --oneline HEAD | cut -d' ' -f1)"
    if [[ "$2" != "$initial_hash" ]]; then
      # If not, add `^` to show commits since the given one:
      blame_cmd="$blame_cmd^"
    fi
  fi

  echo "$blame_cmd -- $1"
}

__fsg_blame () {
  local blame_cmd
  blame_cmd="$(__fsg_blame_cmd "$1")"

  eval "$blame_cmd" |
  _fsg_fzf \
    --bind "ctrl-s:execute:($(__fsg_pager_data) git show \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-b:execute:(source "${__fsg_path:A:h}/fzf-simple-git-common.sh" && _fzf_git_cli \"\$(echo {} | awk '$(__fsg_awk_log)')\")" \
    --bind "ctrl-j:reload(source "${__fsg_path:A:h}/fzf-simple-git-blame.sh"; eval \"\$(__fsg_blame_cmd "$1" \"\$(echo {} | awk '$(__fsg_awk_log)')\")\")" \
    --bind "ctrl-r:reload(source "${__fsg_path:A:h}/fzf-simple-git-blame.sh"; eval \"\$(__fsg_blame_cmd "$1")\")" \
    --preview "echo {} | awk '$(__fsg_awk_log)' | xargs git show | $(__fsg_pager)" |
  awk 'match($0, /[a-f0-9]{8}*/) { print substr($0, RSTART, RLENGTH) }'
}
