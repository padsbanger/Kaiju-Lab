# Pixel Asset Specification

Gameplay sprites are authored and stored at low resolution. They must not be created as smooth paintings and downscaled at runtime.

## Base Rules

- Source canvas: `128 × 128` pixels for kaiju body parts.
- Palette: target 24 colors per asset, with shared near-black, bone, purple, toxic-green, and injury-red ramps.
- Filtering: nearest-neighbor only; no mipmap smoothing.
- Transparency: binary alpha for gameplay silhouettes.
- Camera angle: strict screen-right side profile.
- Light direction: upper left.
- Scale: 48 source pixels per world unit.
- Pivot: center of source canvas; use the parent socket transform for attachment alignment.
- Socket types: `core`, `head`, `arm`, `back`, `tail`, and `mutation`.
- Layering: torso `2`, rear limbs `1`, foreground limbs `4`, head `5`, dorsal mutations `6`.
- Animation: independent component transforms or low-frame-count sprite sequences; use strong poses rather than interpolated blur.
- Damage variants: healthy, damaged, destroyed/offline; regeneration uses a discrete biological pulse.

## Import Validation

- Texture dimensions must remain at or below `128 × 128` for MVP body parts.
- Alpha must have transparent corners and hard silhouette edges.
- `ComponentVisual` enforces nearest filtering and disables billboarding.
- Supported window sizes should be integer multiples of the `640 × 360` logical viewport where practical.
