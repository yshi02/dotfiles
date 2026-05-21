local wezterm = require 'wezterm'

local config = wezterm.config_builder()

--- Import modules

local dynamic_dpi = require 'dynamic_dpi'

--- Appearance

config.initial_cols = 120
config.initial_rows = 36

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_content_alignment = { horizontal = 'Center', vertical = 'Center' }

-- Prevent font-size changes from resizing the outer window
config.adjust_window_size_when_changing_font_size = false

config.color_scheme = 'Raycast_Dark'

-- Dynamically adjust DPI and font size based on display information
dynamic_dpi.setup()

--- Fonts

config.font_size = 14.0
config.font = wezterm.font_with_fallback { 'CommitMono' }

config.bold_brightens_ansi_colors = 'BrightAndBold'

return config
