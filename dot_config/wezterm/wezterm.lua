local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Appearance

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_content_alignment = { horizontal = 'Center', vertical = 'Center' }

config.color_scheme = 'Raycast_Dark'

-- Fonts

config.font_size = 12
config.font = wezterm.font_with_fallback { 'Commit Mono' }

config.bold_brightens_ansi_colors = 'BrightAndBold'

return config
