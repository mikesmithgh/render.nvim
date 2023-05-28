<img src="https://user-images.githubusercontent.com/10135646/225309637-0c194a45-2e37-44fc-9045-610044cdbd90.png" alt="rendersquirrel" style="width: 25%" align="right" />

# 📸 render.nvim
Neovim plugin to take screenshots of your Neovim session on MacOS.

<!-- panvimdoc-ignore-start -->

[![neovim: v0.9+](https://img.shields.io/static/v1?style=for-the-badge&label=neovim&message=v0.9%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![macos: 11+](https://img.shields.io/static/v1?style=for-the-badge&label=macos&message=11%2b&logo=apple&labelColor=282828&logoColor=968c81&color=968c81)](https://www.apple.com/macos)
[![semantic-release: angular](https://img.shields.io/static/v1?style=for-the-badge&label=semantic-release&message=angular&logo=semantic-release&labelColor=282828&logoColor=d8869b&color=8f3f71)](https://github.com/semantic-release/semantic-release)

See [wiki](https://github.com/mikesmithgh/render.nvim/wiki#demos) for all demos

https://github.com/mikesmithgh/render.nvim/assets/10135646/b0398ba7-ae7d-4551-adc6-a021f3aab661

<!-- panvimdoc-ignore-end -->

## ✨ Features
- 📷 Capture image of window by process ID
- 🎥 Capture video recording
- 🟪 Capture image or video by window boundaries
- ✂️  Capture to clipboard
- 💾 Capture to file
- 🔳 Add window's shadow in window capture mode
- 🔢 Take capture after a delay
- 🎧 Play sound effect on capture
- 💥 Flash window on capture
- 🖱️ Show clicks during video recording
- 💅 Show floating thumbnail after capture
- 🏃‍♂️ Open captures in quick view
- 🔧 Open captures in quickfix list
- 🔍 Automatically open or preview capture
- ⏰ Limit capture video recording time
- 📝 Fine-tune cropping of window boundaries
- 🤳 Image formats `png` `jpg` `pdf` `psd` `tga` `bmp` `gif` `tif`
- 🎬 Video format `mov`

## 🫡 Commands
| Command             | Description                                                             |
|---------------------|-------------------------------------------------------------------------|
| Render              | Capture image or video recording                                        |                                                                                               
| RenderClean         | Delete existing captures in output directory and reinstall dependencies |
| RenderExplore       | Open render output directory in Neovim                                  |
| RenderQuickfix      | Open output directory in quickfix window                                |
| RenderInterrupt     | Send interrupt to stop video recoring                                   |
| RenderQuicklook     | Open all files in output directory with quick look                      |
| RenderSetWindowInfo | Set the window information to the active Neovim session                 |

## ⌨️ Keymapping
TODO

## ✍️ Configuration
TODO

## 🟰 Screencapture equivalent
| render.nvim option                        | argument       | description                                                     |
|-------------------------------------------|----------------|-----------------------------------------------------------------|
| `mode_opts.mode = 'clipboard'`            | `-c`           | Force screen capture to go to the clipboard                     |
| `features.window_shadow = false`          | `-o`           | In window capture mode, do not capture the shadow of the window |
| `mode_opts.filetype = '<format>'`         | `-t<format>`   | Image format to create, default is png                          |
| `mode_opts.delay = <seconds>`             | `-T<seconds>`  | Take the picture after a delay of <seconds>                     |
| `features.sound_effect = false`           | `-x`           | Do not play sounds                                              |
| `mode_opts.image_capture_mode = 'window'` | `-l<id>`       | Capture windows by id                                           |
| `mode_opts.image_capture_mode = 'bounds'` | `-R<x,y,w,h>`  | Capture screen rect                                             |
| `mode_opts.type = 'video'`                | `-v`           | Capture video recording of the screen                           |
| `mode_opts.show_clicks = true`            | `-k`           | Show clicks in video recording mode                             |
| `mode_opts.mode = 'preview'`              | `-u`           | Present UI after screencapture is complete                      |

## 📦 Installation

### Prerequisites and Dependencies
| Name                                                      | Description                                                  | Installation Method       |
|-----------------------------------------------------------|--------------------------------------------------------------|---------------------------|
| [Neovim v0.9+](https://github.com/neovim/neovim/releases) | Neovim version 0.9 or greater                                | User installed            |
| [screencapture](https://ss64.com/osx/screencapture.html)  | Captures image and video of the whole, or part of the screen | Included on Mac           |
| [qlmanage](https://ss64.com/osx/qlmanage.html)            | Displays quick look previews                                 | Included on Mac           |
| [pdubs](https://github.com/mikesmithgh/pdubs)             | Retreives window information for the Neovim session          | Downloaded by render.nvim |
| `curl`, `shasum`, `tar`                                   | Required to download, extract, and verify `pdubs` binary     | Included on Mac           |

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
- 🐿️ [gruvsquirrel.nvim](https://github.com/mikesmithgh/gruvsquirrel.nvim) Neovim colorscheme written in Lua inspired by gruvbox
- 🦬 [pdubs](https://github.com/mikesmithgh/pdubs) A simple command-line utility to return macos window information for a given pid.
