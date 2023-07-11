# Contribution Guide

## How to start development

### Setup

1. Install [Nix](https://nixos.org/) package manager
2. Run `nix-shell` or `nix-shell --command 'zsh'`
3. You can use development tools

```console
$ npm install
$ dprint check
```

If you use vscode, installing elm-test, elm-format and elm-review into global might make better experience.
(Currently not installing them with Nix)

### Like a hot reload

Open 3 tabs/windows in your terminal

1. `deno task watch-elm`
1. `deno task watch-bridge`
1. `deno task serve`

## CSS naming convention

[rscss](https://github.com/rstacruz/rscss)

## Deployment

main branch and PRs will be deployed to firebase with [GitHub Actions](.github/workflows/)

## Cat meow as the bell

:cat:

<a href="https://commons.wikimedia.org/wiki/File:Meow.ogg">The original uploader was Dcrosby at English Wikipedia.</a>, <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a>, via Wikimedia Commons
