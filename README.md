# render.nvim
Work in Progress

## Proof of Concept
Screenshot taken with render.nvim
![nvim-screenshot](https://user-images.githubusercontent.com/10135646/224209313-cacf8d31-a64e-485d-947c-1cca691f24f8.png)

## Installation

### Prerequisites
- Install [aha](https://github.com/theZiz/aha)
- Install [phantomjs](https://github.com/ariya/phantomjs)

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
