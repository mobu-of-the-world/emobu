# Contribution Guide

## How to start development

### Setup

Needs elm and nodejs for development.\
Author is using [asdf](https://asdf-vm.com/) to install them.\
This repository manage the language versions with [.tool-versions](.tool-versions). So you can install them as below.

`asdf install`

Them requires to install npm dependencies.

`npm install`

### `npm run dev`

Runs the app in the development mode.<br />
Open [http://localhost:5173/](http://localhost:5173/) to view it in your browser.

The page will reload when you make changes.<br />

NOTE: This project is developped by elm, however this hot reloading uses vite for now.

### `npm run check`

Run linters, formatters, and tests. You can dig further detail in [task scripts](package.json).
Especially recommend to visit the section about [elm-test](https://package.elm-lang.org/packages/elm-explorations/test/latest) for the test runner.

### `npm run build`

Builds the app for production to the `dist` folder.<br />

## CSS naming convention

[rscss](https://github.com/rstacruz/rscss)

## Deployment

main branch and PRs will be deployed to firebase with [GitHub Actions](.github/workflows/)

## Cat meow as the bell

:cat:

<a href="https://commons.wikimedia.org/wiki/File:Meow.ogg">The original uploader was Dcrosby at English Wikipedia.</a>, <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a>, via Wikimedia Commons
