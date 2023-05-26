<img src="https://user-images.githubusercontent.com/10135646/225309637-0c194a45-2e37-44fc-9045-610044cdbd90.png" alt="rendersquirrel" style="width: 25%" align="right" />

# 📸 render.nvim
Neovim plugin to take screenshots of your Neovim session on MacOS.

## ✨ Features
- ✂️ Capture to clipboard

https://github.com/mikesmithgh/render.nvim/assets/10135646/aa0e0ad4-d402-4a2d-aacb-8c60755746ea

- 💾 Save capture to file
- 🆔 Capture image by Window
- 🟪 Capture image or video by Window bounds
- 🔳 Decorate capture with Window shadow
  - With shadow
![render-nvim-shadow](https://github.com/mikesmithgh/render.nvim/assets/10135646/19b7324e-c90d-4f13-828e-144bc53b9289)
  - Without shadow

![render-nvim-no-shadow](https://github.com/mikesmithgh/render.nvim/assets/10135646/6916d741-95b5-4d9a-b77c-cd23eda47bc5)


- 🔢 Configurable delay with countdown

https://github.com/mikesmithgh/render.nvim/assets/10135646/bffe65ff-891b-4726-bfb8-0b4cbf574a2b

- 🎧 Sound effect

(Watch with sound on)

https://github.com/mikesmithgh/render.nvim/assets/10135646/6a97a683-fd63-4546-b7f9-5762d1d6ea4f

- 💥 Flash

https://github.com/mikesmithgh/render.nvim/assets/10135646/46300927-097a-4c55-b1c6-2b9f39fd77ca

- 🎥 Video recording
- 🖱️ Show clicks during video recording

https://github.com/mikesmithgh/render.nvim/assets/10135646/4e1b1df2-384d-407b-b6b0-0400e55ff66c

- 💅 Show floating thumbnail

https://github.com/mikesmithgh/render.nvim/assets/10135646/13bd13ec-e352-4ee1-8bb6-5327c1cc27e5

- 🏃‍♂️ Open all screencaptures in Quick View
- 🔧 Open all screencaptures in Quickfix List
- 🔍 Open or Preview capture
- ⏰ Limit Video recording length
- 🤳 Multiple image formats supported
  - `png` `jpg` `pdf` `psd` `tga` `bmp` `gif` `tif`
- 🎬 `mov` Video format support
- 📝 Configurable bound cropping

<!-- panvimdoc-ignore-start -->

[![neovim: v0.9+](https://img.shields.io/static/v1?style=for-the-badge&label=neovim&message=v0.9%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![macos: 11+](https://img.shields.io/static/v1?style=for-the-badge&label=macos&message=11%2b&logo=apple&labelColor=282828&logoColor=968c81&color=968c81)](https://www.apple.com/macos)
[![semantic-release: angular](https://img.shields.io/static/v1?style=for-the-badge&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)

https://user-images.githubusercontent.com/10135646/224586255-bbb49b38-f363-4389-a40b-790efa4121f8.mov

<!-- panvimdoc-ignore-end -->

## 📦 Installation

### Prerequisites and Dependencies
| Name | Description | Installation Method |
|-|-|-|
| [Neovim v0.9+](https://github.com/neovim/neovim/releases) | Neovim version 0.9 or greater | User installed |
| [screencapture](https://ss64.com/osx/screencapture.html) | Captures image and video of the whole, or part of the screen | Included on Mac |
| [qlmanage](https://ss64.com/osx/qlmanage.html) |  Displays Quick Look previews | Included on Mac |
| [pdubs](https://github.com/mikesmithgh/pdubs) | Retreives window information for the Neovim session | Downloaded by render.nvim |
| `curl`, `shasum`, `tar` | Required to download, extract, and verify `pdubs` binary | Included on Mac |

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
  {
    "mikesmithgh/render.nvim",
    config = function()
      require("render").setup()
    end,
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
- Window information such as window ID, size and position are determined for the current process using [pdubs](https://github.com/mikesmithgh/pdubs)
- Window information and configuration options are parsed and translated to a [screencapture](https://ss64.com/osx/screencapture.html) command

## 🍎 Supported OS versions
- macOS 13 Ventura
- macOS 12 Monterey
- macOS 11 Big Sur

## 🔒 Privacy & Security
Screen recording must be enabled in order for render.nvim to take screencaptures. This will need to be enabled for the application that is running Neovim. For example, Kitty, Alacritty, iTerm2, Neovide, etc. The first time you attempt to take a screenshot, you may see a prompt to allow access.

![screencapture-prompt](https://github.com/mikesmithgh/render.nvim/assets/10135646/e363c75f-4b00-489b-b0ea-17215a0d37cb)

Open System Settings and enable screen recording for your application.

- Choose Apple menu 🍎 > System Settings, then click Privacy & Security ✋ in the sidebar. (You may need to scroll down.)
- Click Screen Recording.
- Turn screen recording on or off for each app in the list.

![screencapture-settings](https://github.com/mikesmithgh/render.nvim/assets/10135646/8fe09d3f-2427-4633-abf2-a54e9c9b8fb4)

## 🤝 Ackowledgements
- 🐿️ [gruvsquirrel.nvim](https://github.com/mikesmithgh/gruvsquirrel.nvim)
- 🦬 [pdubs](https://github.com/mikesmithgh/pdubs)
