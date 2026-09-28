-- Frosted desktop widget surfaces. Load after other appearance settings.
-- Hyprland's blur engine is global; only matching layer surfaces opt in here.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
    },
  },
})

hl.layer_rule({
  name = "neon-district-widget-blur",
  match = { namespace = "^neon-district-weather$" },
  blur = true,
  -- Do not blur the transparent pixels outside the chamfered silhouette.
  ignore_alpha = 0.01,
})
