# fzf-simple-git

`fzf` plugin for zsh to enable smart suggestions for common `git` use-cases.


## Features

### git log

`ctlr-g` + `ctrl-l` (for l-og) opens up `git log` of all commits

https://raw.githubusercontent.com/sobolevn/fzf-simple-git/master/media/fzf-simple-git-log.mp4

From there:
- `ctrl-s` (for s-how) to open `git show` for a single commit
- `ctrl-d` (for d-iff) to show `git diff` since that commit
- `ctrl-b` (for b-rowser) to open GitHub in a browser with the commit, requires [`gh`](https://github.com/cli/cli)

Common keys:
- `tab` to select multiple entries
- `ctrl+h` (for h-ide) to hide preview window


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
