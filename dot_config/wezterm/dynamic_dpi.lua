local wezterm = require 'wezterm'

local M = {}

M.name = "dynamic_dpi"

-- Physical monitor sizes in inches.
--
-- Key format:
--   by_name:
--     "<display name>"
--   exact:
--     "<display name>|<width>|<height>|<scale>"
--
-- For exact matches, width/height/scale are necessary because some
-- displays share the same human-readable name
-- (e.g. "Built-in Retina Display" on different MacBook models).
--
-- The value is the physical diagonal size of the panel in inches.
local PHYSICAL_SIZES = {
  by_name = {
    ['DELL P3221D'] = 31.5,
  },

  exact = {
    -- MacBook Air since M2
    ['Built-in Retina Display|2560|1664|2.0'] = 13.6,
    ['Built-in Retina Display|2940|1912|2.0'] = 13.6,
    ['Built-in Retina Display|3420|2224|2.0'] = 13.6,
  },
}

-- Build a stable lookup key for a wezterm.gui.screens() exact entry
local function screen_key(screen)
  return string.format(
    '%s|%s|%s|%s',
    screen.name,
    screen.width,
    screen.height,
    screen.scale
  )
end

-- Lookup the display panel's physical size.
--
-- Exact key matches take priority over name matches.
local function lookup_display_size(screen)
  local exact_key = screen_key(screen)

  if PHYSICAL_SIZES.exact[exact_key] then
    return PHYSICAL_SIZES.exact[exact_key], exact_key
  end

  if PHYSICAL_SIZES.by_name[screen.name] then
    return PHYSICAL_SIZES.by_name[screen.name], screen.name
  end

  return nil, exact_key
end

-- Compute the physical DPI/PPI of a display.
local function calculate_dpi(width, height, diagonal_inches)
  local dpi =
    math.sqrt(width * width + height * height) / diagonal_inches

  -- Round to nearest integer because some compositors
  -- may not support fractional scaling
  return math.floor(dpi + 0.5)
end

-- Apply DPI override for the active screen.
local function apply_active_screen_dpi(window)
  local screen = wezterm.gui.screens().active
  if not screen then
    wezterm.log_info(string.format('%s: unable to find active screen', M.name))
    return
  end

  local display_size, key = lookup_display_size(screen)
  if not display_size then
    wezterm.log_info(string.format('%s: no physical size override for %s', M.name, key))
    return
  end

  -- Compute true DPI from physical panel size.
  local physical_dpi = calculate_dpi(
    screen.width / screen.scale,
    screen.height / screen.scale,
    display_size
  )

  local overrides = window:get_config_overrides() or {}

  local current_effective_dpi =
    overrides.dpi_by_screen
    and overrides.dpi_by_screen[screen.name]

  -- Avoid repeatedly applying identical overrides.
  if current_effective_dpi == physical_dpi then
    return
  end

  wezterm.log_info(
    string.format(
      '%s: overriding "%s": dpi: %s -> %s',
      M.name,
      screen.name,
      tostring(current_effective_dpi),
      physical_dpi
    )
  )

  overrides.dpi_by_screen = { [screen.name] = physical_dpi }
  window:set_config_overrides(overrides)
end

-- Setup dynamic DPI overrides.
--
-- Example:
--
--   local dynamic_dpi = require 'dynamic_dpi'
--   dynamic_dpi.setup()
function M.setup()
  -- Recompute when config reloads.
  wezterm.on('window-config-reloaded', apply_active_screen_dpi)

  -- Recompute when resized or moved across displays.
  wezterm.on('window-resized', apply_active_screen_dpi)
end

return M

--- References:
-- https://wezterm.org/config/lua/config/dpi.html
-- https://github.com/wezterm/wezterm/issues/4096
