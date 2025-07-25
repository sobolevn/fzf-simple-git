# fzf-simple-git

`fzf` plugin for zsh to enable smart suggestions for common `git` use-cases.


## Features

All commands require `ctrl-g` (for g-it) to be pressed before the actual command.

### help

`ctrl-g` + `ctrl-h` (for h-elp) opens up usage guide.

### git log

`ctlr-g` + `ctrl-l` (for l-og) opens up `git log` of all commits.

https://github.com/user-attachments/assets/093201a6-3d0c-43ad-b00d-3a27f802bb92

From there:
- `ctrl-s` (for s-how) to open `git show` for a single commit
- `ctrl-d` (for d-iff) to show `git diff` since that commit
- `ctrl-b` (for b-rowser) to open GitHub in a browser with the commit, requires [`gh`](https://github.com/cli/cli)

### git branch

`ctlr-g` + `ctrl-b` (for b-ranch) opens `git branch` of recent branches.

https://github.com/user-attachments/assets/ca4bd15b-531b-48e4-8599-b641dd90b8dd

From there:
- `ctrl-s` (for s-how) to open `git show` for a single commit
- `ctrl-d` (for d-iff) to show `git diff` since that commit
- `ctrl-b` (for b-rowser) to open GitHub in a browser with the commit, requires [`gh`](https://github.com/cli/cli)

### git files and git blame

`ctrl-g` + `ctrl-f` (for f-files) opens `git ls-files`.

https://github.com/user-attachments/assets/2e0baad4-ecc8-4c05-b963-59c0653f6869

From there:
- `ctrl+o` (for o-pen) to open a file in `$EDITOR`
- `ctrl+b` (for b-rowser) to open in browser (`gh` is required)
- `ctrl+d` (for d-eleted) to show deleted files
- `ctrl+r` (for r-eload) to reload files
- `ctrl+j` (for j-ump to blame) to show `git blame` for this file

This view has its own features:
- `ctrl+s` (for s-how) to open that commit with `show`
- `ctrl+j` (for j-ump to blame)  to show the `git blame` before the selected commit
- `ctrl+r` (for r-eload) to reload `git blame` for this file
- `ctrl+b` (for b-rowser) to open in browser (`gh` is required)

### Common controlls

- `<tab>` to select multiple entries
- `ctrl+h` (for h-ide) to hide preview window
- `ctrl+]` to show help in a preview window


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
1. Via `$FZF_DEFAULT_OPTS` which are respected, recommended
2. Via redefining `_fsg_fzf` function, it is not recommended, but works

You can customize how `pager` behaves with setting `$FSG_PAGER`
(defaults to `delta` if installed and to `less` if not).

You can customize `delta`'s syntax theme if it is intalled with `$FSG_BAT_THEME`,
(defaults to `$BAT_THEME` or `ansi`).


## License

[MIT](https://github.com/sobolevn/fzf-simple-git/blob/master/LICENSE.md?plain=1)
