this is a test

# :camera: render.nvim
Neovim plugin to take screenshots of your Neovim session.
> :camera::warning::camera: This project is still a work in progress and may have breaking changes :camera::warning::camera:

This plugin is under early development. If you have any ideas, feedback, or bugs please open an issue! 

## Demo
https://user-images.githubusercontent.com/10135646/224586255-bbb49b38-f363-4389-a40b-790efa4121f8.mov

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
