<img src="https://user-images.githubusercontent.com/10135646/225309637-0c194a45-2e37-44fc-9045-610044cdbd90.png" alt="rendersquirrel" style="width: 25%" align="right" />

# 📸 render.nvim
Neovim plugin to take screenshots of your Neovim session.

<!-- panvimdoc-ignore-start -->

[![neovim: v0.9+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.9%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![aha: v0.5.1](https://img.shields.io/static/v1?style=flat-square&label=aha&message=v0.5.1&labelColor=282828&color=dbbc5f&logoWidth=10&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAE9SURBVHhe7dJBAQAgDAAhm66oTQwzg3APGnDenY2rALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4AqAKwCuALgC4ApAm/2Zc0sUAj5geAAAAABJRU5ErkJggg==)](https://github.com/theZiz/aha)<!-- search: https://www.htmlcsscolor.com/hex/DBBC5F and encode: https://www.base64-image.de/  -->
[![playwright: v1.32.0](https://img.shields.io/static/v1?style=flat-square&label=playwright&message=v1.32.0&logo=playwright&labelColor=282828&logoColor=ff6961&color=ff6961)](https://playwright.dev/)
[![semantic-release: angular](https://img.shields.io/static/v1?style=flat-square&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)

<!-- panvimdoc-ignore-end -->

>:camera::warning::camera: This project is still a work in progress and may have breaking changes :camera::warning::camera:

This plugin is under early development. If you have any ideas, feedback, or bugs please open an issue!

<!-- panvimdoc-ignore-start -->

https://user-images.githubusercontent.com/10135646/224586255-bbb49b38-f363-4389-a40b-790efa4121f8.mov

<!-- panvimdoc-ignore-end -->

## 📦 Installation

### Prerequisites
- Neovim [v0.9+](https://github.com/neovim/neovim/releases)
- Install [aha](https://github.com/theZiz/aha)
- Install [playwright](https://playwright.dev/)

### Privacy & Security
- accessibilty -> required for window dimensions. will receive an error that we can handle to notify user
- screen recording -> required for screenshot. will silently fail and only take a screenshot of desktop

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

### Using Neovim's built-in package support [pack](https://neovim.io/doc/user/usr_05.html#05.4)
```bash
mkdir -p "$HOME/.local/share/nvim/site/pack/mikesmithgh/start/"
cd $HOME/.local/share/nvim/site/pack/mikesmithgh/start
git clone git@github.com:mikesmithgh/render.nvim.git
nvim -u NONE -c "helptags render.nvim/doc" -c q
echo "require('render').setup()" >> "$HOME/.config/nvim/init.lua" 
```

<!-- panvimdoc-ignore-start -->

## 👇 Example
Neovim intro screen captured with render.nvim

![intro screenshot](https://raw.githubusercontent.com/wiki/mikesmithgh/render.nvim/ci/main/output/intro.png)

<!-- panvimdoc-ignore-end -->

## 🤷 How does it work?
1. render.nvim calls the `vim.api.nvim__screenshot` API to create a `.cat` file containing ANSI escape sequences representing the current Neovim session. This is an undocumented API and may be at risk of breaking changes.
2. Converts the `.cat` file to `.html` via [aha](https://github.com/theZiz/aha).
3. Converts the `.html` file to `.png` via [playwright](https://playwright.dev/). Playwright spins up a headless chromium browser of the `.html` page and captures the screenshot.

## 🤝 Ackowledgements
- [aha - Ansi HTML Adapter](https://github.com/theZiz/aha) 
    > Converts ANSI escape sequences of a unix terminal to HTML code.
- [playwright](https://github.com/microsoft/playwright)
    > Playwright is a framework for Web Testing and Automation. It allows testing Chromium, Firefox and WebKit with a single API. Playwright is built to enable cross-browser web automation that is ever-green, capable, reliable and fast.
- [MonaLisa](https://www.monolisa.dev/) 
    > MonoLisa is a font that was designed by professionals to improve developers’ productivity and reduce fatigue.
- [monalisa-nerdfont-patch](https://github.com/daylinmorgan/monolisa-nerdfont-patch) 
    > Most Batteries included repo to patch MonoLisa with Nerd Fonts glyphs
