# [2.0.0](https://github.com/mikesmithgh/render.nvim/compare/v1.3.1...v2.0.0) (2024-04-22)


* feat!: rewrite to only use screencapture on MacOS ([a3382cc](https://github.com/mikesmithgh/render.nvim/commit/a3382cc16681e4efd7e97d8490f1af82f31e4a8f))


### BREAKING CHANGES

* rewrite to no longer support playwright approach. render.nvim now uses screencapture and only supports MacOS

## [1.3.1](https://github.com/mikesmithgh/render.nvim/compare/v1.3.0...v1.3.1) (2023-04-10)


### Bug Fixes

* remove en space in screenshot ([#32](https://github.com/mikesmithgh/render.nvim/issues/32)) ([fca1c74](https://github.com/mikesmithgh/render.nvim/commit/fca1c74db451b0b7e2332d4bfc7440686b168cdf))

# [1.3.0](https://github.com/mikesmithgh/render.nvim/compare/v1.2.1...v1.3.0) (2023-04-04)


### Features

* add scale option to render size closes [#23](https://github.com/mikesmithgh/render.nvim/issues/23) ([#27](https://github.com/mikesmithgh/render.nvim/issues/27)) ([ac84519](https://github.com/mikesmithgh/render.nvim/commit/ac845190bcc6375b6a5c07c89244aa405c8c38ca))

## [1.2.1](https://github.com/mikesmithgh/render.nvim/compare/v1.2.0...v1.2.1) (2023-04-03)


### Bug Fixes

* strip out ^O character from ANSI (tmux/screen) ([#26](https://github.com/mikesmithgh/render.nvim/issues/26)) ([36e2dc0](https://github.com/mikesmithgh/render.nvim/commit/36e2dc0da70e4dcca342f01669f8944cad3dca18))

# [1.2.0](https://github.com/mikesmithgh/render.nvim/compare/v1.1.2...v1.2.0) (2023-04-03)


### Features

* add notify.level option ([#25](https://github.com/mikesmithgh/render.nvim/issues/25)) ([db3d460](https://github.com/mikesmithgh/render.nvim/commit/db3d460c58b6837c124ac5368c0db160ee839277))

## [1.1.2](https://github.com/mikesmithgh/render.nvim/compare/v1.1.1...v1.1.2) (2023-03-31)


### Bug Fixes

* add timeout for cat file read ([#17](https://github.com/mikesmithgh/render.nvim/issues/17)) ([acbe8ce](https://github.com/mikesmithgh/render.nvim/commit/acbe8ce95e3682b353284ea1fe490b0a044329f1))

## [1.1.1](https://github.com/mikesmithgh/render.nvim/compare/v1.1.0...v1.1.1) (2023-03-16)


### Bug Fixes

* Add neovim nightly requirement ([#12](https://github.com/mikesmithgh/render.nvim/issues/12)) ([3cd4e68](https://github.com/mikesmithgh/render.nvim/commit/3cd4e68bfeaa2d61a301b0c7464f7f553f3c1b98))

# [1.1.0](https://github.com/mikesmithgh/render.nvim/compare/v1.0.0...v1.1.0) (2023-03-14)


### Features

* font customization and default to MonaLisa ([#6](https://github.com/mikesmithgh/render.nvim/issues/6)) ([bfc68aa](https://github.com/mikesmithgh/render.nvim/commit/bfc68aa27f78659ee9d1c71341ed2e4e69e5c93c))

# 1.0.0 (2023-03-13)


### Bug Fixes

* normalize name and only capture pre tag ([df0408b](https://github.com/mikesmithgh/render.nvim/commit/df0408b85fcb293a702c1918b6bfe9d628b74272))
* use mode intsead of redraw ([02e5041](https://github.com/mikesmithgh/render.nvim/commit/02e5041b0e967123f351b498a6a97742269893e6))


### Features

* add flash ([824dad6](https://github.com/mikesmithgh/render.nvim/commit/824dad6f17f2e46315d65591c214ac804afa6386))
* auto open ([d63d0ea](https://github.com/mikesmithgh/render.nvim/commit/d63d0ea8228346361ccde1a499607bf9337b6a0d))
* quickfix list and open command ([a06fc5e](https://github.com/mikesmithgh/render.nvim/commit/a06fc5e600464cabcc575751b5f4e287b7b42e65))
* use playwright instead of phantomjs ([352edbd](https://github.com/mikesmithgh/render.nvim/commit/352edbd08d162e9f5d9a4db5e5b374a825bbc561))
