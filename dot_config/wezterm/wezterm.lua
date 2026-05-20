local wezterm = require 'wezterm'

local config = wezterm.config_builder()

---- Appearance

config.initial_cols = 120
config.initial_rows = 36

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_content_alignment = { horizontal = 'Center', vertical = 'Center' }

-- Prevent font-size changes from resizing the outer window
config.adjust_window_size_when_changing_font_size = false

config.color_scheme = 'Raycast_Dark'

---- Fonts

-- To dynamically adjust font size across different displays,
-- calculate the font size based on dpi and target font pixels
-- 1 pt = 1/72 inch ==> device pixels = font_size * dpi / 72
local function apply_dpi_font_size(window)
    local TARGET_FONT_PIXELS = 32

    local dpi = window:get_dimensions().dpi
    local font_size = TARGET_FONT_PIXELS * 72 / dpi

    local overrides = window:get_config_overrides() or {}

    if overrides.font_size ~= font_size then
        overrides.font_size = font_size
        window:set_config_overrides(overrides)
    end
end

wezterm.on('window-config-reloaded', function(window)
  apply_dpi_font_size(window)
end)

wezterm.on('window-resized', function(window)
  apply_dpi_font_size(window)
end)

config.font = wezterm.font_with_fallback { 'CommitMono' }

config.bold_brightens_ansi_colors = 'BrightAndBold'

return config
