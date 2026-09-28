-- Optional appearance overrides for Neon District. Load after other appearance plugins.
local theme_file = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme.name", "r")
if not theme_file then return end
local theme_name = theme_file:read("*l")
theme_file:close()
if theme_name ~= "neon-district" then return end

local gradient = { colors = { "rgba(36f9f6ee)", "rgba(ff4f9aee)" }, angle = 45 }
hl.config({
  general = {
    col = { active_border = gradient, inactive_border = "rgba(383054aa)" },
  },
  decoration = {
    shadow = {
      enabled = true,
      range = 18,
      render_power = 3,
      color = "rgba(713d9e55)",
      color_inactive = "rgba(15102333)",
    },
  },
})

-- Match an existing shiny/ripple border without changing its animation settings.
for _, plugin in ipairs(hl.get_loaded_plugins()) do
  if plugin.name == "hypr-shiny-border" then
    hl.config({ plugin = { shiny_border = {
      col = { a = "rgba(36f9f6ee)", b = "rgba(ff4f9aee)" },
      base_color = "rgba(383054aa)",
      gradient = gradient,
      gradient_positions = "0 100",
      gradient_cw = gradient,
      gradient_positions_cw = "0 100",
    } } })
  end
end
