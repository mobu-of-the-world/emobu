# Contribution Guide

## How to start development

### Setup

1. Install [Nix](https://nixos.org/) package manager
2. Run `nix develop` or `nix develop --command 'zsh'` or `direnv allow` (if you have [direnv](https://github.com/direnv/direnv))
3. You can use development tools

```console
$ npm install
$ dprint check
```

If you use vscode, installing elm-test, elm-format and elm-review into global might make better experience.
(Currently not installing them with Nix)

### `npm run dev`

Runs the app in the development mode.
Open [http://localhost:5173/](http://localhost:5173/) to view it in your browser.

The page will reload when you make changes.

NOTE: This project is developed by elm, however this hot reloading uses vite for now.

### `npm run check`

Run linters, formatters, and tests. You can dig further detail in [task scripts](package.json).\
Especially recommend to visit the section about [elm-test](https://package.elm-lang.org/packages/elm-explorations/test/latest) for the test runner.

### `npm run build`

Builds the app for production to the `dist` folder.

## CSS naming convention

[rscss](https://github.com/rstacruz/rscss)

## Deployment

main branch and PRs will be deployed to firebase with [GitHub Actions](.github/workflows/)

## Cat meow as the bell

:cat:

<a href="https://commons.wikimedia.org/wiki/File:Meow.ogg">The original uploader was Dcrosby at English Wikipedia.</a>, <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a>, via Wikimedia Commons
