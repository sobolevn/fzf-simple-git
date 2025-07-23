# fzf-simple-git

`fzf` plugin for zsh to enable smart suggestions for common `git` use-cases.


## Features

### git log

`ctlr-g` + `ctrl-l` (for l-og) opens up `git log` of all commits

https://github.com/user-attachments/assets/093201a6-3d0c-43ad-b00d-3a27f802bb92

From there:
- `ctrl-s` (for s-how) to open `git show` for a single commit
- `ctrl-d` (for d-iff) to show `git diff` since that commit
- `ctrl-b` (for b-rowser) to open GitHub in a browser with the commit, requires [`gh`](https://github.com/cli/cli)

Common keys:
- `tab` to select multiple entries
- `ctrl+h` (for h-ide) to hide preview window


## Installation

With [`zplug`](https://github.com/zplug/zplug):
1. Add `zplug 'sobolevn/fzf-simple-git', depth:1` to your plugin list

With [`antigen`](https://github.com/zsh-users/antigen):
1. Add `antigen bundle sobolevn/fzf-simple-git` to your plugin list

With `oh-my-zsh`:
1. `git clone https://github.com/sobolevn/fzf-simple-git.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-simple-git`
2. Add `fzf-simple-git` to the list of `plugins=(fzf-simple-git, ...)`


## Configuration

You can fully customize how default `fzf` behaves in two ways:
1. Via `FZF_DEFAULT_OPTS` which are respected, recommended
2. Via redefining `_fsg_fzf` function, it is not recommended, but works

You can customize how `pager` behaves if you override `_fsg_pager`, example:

```sh
_fsg_pager () {
  echo 'bat'
}
```


## License

[MIT](https://github.com/sobolevn/fzf-simple-git/blob/master/LICENSE.md?plain=1)
