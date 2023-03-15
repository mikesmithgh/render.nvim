<!-- panvimdoc-ignore-start -->
<img src="https://user-images.githubusercontent.com/10135646/225309637-0c194a45-2e37-44fc-9045-610044cdbd90.png" alt="rendersquirrel" style="width: 25%" align="right" />
<!-- panvimdoc-ignore-end -->

# render.nvim
Neovim plugin to take screenshots of your Neovim session.

<!-- panvimdoc-ignore-start -->
[![neovim: nightly](https://img.shields.io/static/v1?style=for-the-badge&label=neovim&message=nightly&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![semantic-release: angular](https://img.shields.io/static/v1?style=for-the-badge&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)
<!-- panvimdoc-ignore-end -->

>:camera::warning::camera: This project is still a work in progress and may have breaking changes :camera::warning::camera:

This plugin is under early development. If you have any ideas, feedback, or bugs please open an issue!

## Demo
https://user-images.githubusercontent.com/10135646/224586255-bbb49b38-f363-4389-a40b-790efa4121f8.mov

<!-- panvimdoc-ignore-end -->

## Installation

### Prerequisites
- Install [aha](https://github.com/theZiz/aha)
- Install [playwright](https://playwright.dev/)

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
  {
    "mikesmithgh/render.nvim",
    config = function()
      require("render").setup()
    end,
  },
}
```

### How does it work?
1. render.nvim calls the `vim.api.nvim__screenshot` API to create a `.cat` file containing ANSI escape sequences representing the current Neovim session. This is an undocumented API and may be at risk of breaking changes.
2. Converts the `.cat` file to `.html` via [aha](https://github.com/theZiz/aha).
3. Converts the `.html` file to `.png` via [playwright](https://playwright.dev/). Playwright spins up a headless chromium browser of the `.html` page and captures the screenshot.

# Ackowledgements
- [MonaLisa](https://www.monolisa.dev/) 
    > MonoLisa is a font that was designed by professionals to improve developers’ productivity and reduce fatigue.
- [monalisa-nerdfont-patch](https://github.com/daylinmorgan/monolisa-nerdfont-patch) 
    > Most Batteries included repo to patch MonoLisa with Nerd Fonts glyphs
